import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/database.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/app/services/error_reporter.dart';
import 'package:sousvite/features/account/sync/application/photo_sync.dart';
import 'package:sousvite/features/account/sync/application/sync_source.dart';
import 'package:sousvite/features/account/sync/application/sync_source_controller.dart';
import 'package:sousvite/features/account/sync/application/sync_state.dart';
import 'package:sousvite/features/account/sync/application/sync_transport.dart';
import 'package:sousvite/features/account/sync/data/drive_access.dart';
import 'package:sousvite/shared/photos/photos.dart';
import 'package:sync/sync.dart';

part 'sync_controller.g.dart';

/// Syncs recipe photos after each space syncs.
@Riverpod(keepAlive: true)
PhotoSync photoSync(Ref ref) => PhotoSync(
  recipes: ref.watch(recipeRepositoryProvider),
  spaces: ref.watch(recipeSpaceRepositoryProvider),
  photos: ref.watch(photoStoreProvider),
  settings: ref.watch(appDatabaseProvider).settingsDao,
);

/// Keeps the library in sync with the chosen cloud while the app runs
/// (ENGINEERING.md §8.2 and §10).
///
/// It syncs when it starts, a moment after each local change, when the
/// app comes back to the foreground, and when the transport says other
/// devices pushed (Firestore's listener) or every few minutes (Drive). The
/// first sync through a transport, and the first after switching to it,
/// copies the whole library into it as a snapshot (the `replay()` of
/// ENGINEERING.md §8.2) and pushes this device's own changes, which is how
/// signing in for the first time and switching sources lose nothing.
@Riverpod(keepAlive: true)
class SyncController() extends _$SyncController {
  /// How long after a local change the push waits, so a burst of edits
  /// goes up as one push.
  static const debounce = Duration(seconds: 2);

  /// How often a transport without a listener is polled.
  static const pollEvery = Duration(minutes: 3);

  /// The private library's engine first, then one per joint share, each
  /// with its space.
  var _engines = <(SyncEngine, SpaceTransport)>[];
  Future<void>? _running;
  var _replayNext = false;
  var _again = false;
  Timer? _soon;

  @override
  SyncState build() {
    final spaces = [
      ?ref.watch(syncTransportProvider),
      ...ref.watch(sharedSyncTransportsProvider),
    ];
    _engines = [];
    if (spaces.isEmpty) return const SyncState(phase: .off);
    final recorder = ref.watch(changeRecorderProvider).requireValue;
    final store = ref.watch(syncLocalStoreProvider);
    _engines = [
      for (final space in spaces)
        (
          SyncEngine(
            store: store,
            transport: space.transport,
            clock: recorder.clock,
            transportKey: space.key,
            spaceId: space.spaceId,
          ),
          space,
        ),
    ];
    final database = ref.watch(appDatabaseProvider);
    final subscriptions = <StreamSubscription<void>>[
      // Every local write appends to the change log. Pulls append too, which
      // costs one quiet extra sync.
      database
          .tableUpdates(TableUpdateQuery.onTable(database.changeLog))
          .listen((_) => _syncSoon()),
      for (final space in spaces)
        if (space.transport case final LiveSyncTransport live)
          live.remoteChanges().listen((_) => _syncSoon(), onError: (_) {}),
    ];
    final poll = spaces.every((space) => space.transport is LiveSyncTransport)
        ? null
        : Timer.periodic(pollEvery, (_) => unawaited(sync()));
    final lifecycle = AppLifecycleListener(onResume: () => unawaited(sync()));
    ref.onDispose(() {
      for (final subscription in subscriptions) {
        unawaited(subscription.cancel());
      }
      poll?.cancel();
      _soon?.cancel();
      lifecycle.dispose();
    });
    unawaited(Future.microtask(sync));
    return const SyncState(phase: .syncing);
  }

  void _syncSoon() {
    _soon?.cancel();
    _soon = Timer(debounce, () => unawaited(sync()));
  }

  /// Syncs now. A call while a sync runs makes it run once more after.
  Future<void> sync() {
    if (_running case final running?) {
      _again = true;
      return running;
    }
    return _running = _syncLoop().whenComplete(() => _running = null);
  }

  Future<void> _syncLoop() async {
    do {
      _again = false;
      await _syncOnce();
    } while (_again && ref.mounted);
  }

  Future<void> _syncOnce() async {
    final engines = _engines;
    if (engines.isEmpty || !ref.mounted) return;
    state = state.to(.syncing);
    try {
      final store = ref.read(syncLocalStoreProvider);
      final photos = ref.read(photoSyncProvider);
      for (final (index, (engine, space)) in engines.indexed) {
        final fresh =
            await store.progress(engine.transportKey) == const SyncProgress();
        final switched = index == 0 && _replayNext;
        if (fresh || switched) {
          // First sync through this transport, or a switch to it: copy the
          // whole current state as a snapshot (replay), and push every own
          // change it hasn't had, so its log keeps their history too.
          await engine.writeSnapshot();
          if (switched) _replayNext = false;
        }
        await engine.sync();
        await engine.snapshotIfDue();
        await photos.run(
          spaceId: space.spaceId,
          key: space.key,
          store: space.photos,
        );
      }
      if (ref.mounted) state = state.to(.synced, lastSyncedAt: clock.now());
    } on DriveSignInRequired {
      if (ref.mounted) state = state.to(.signInAgain);
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return;
      if (_isOffline(error)) {
        state = state.to(.offline);
      } else {
        state = state.to(.error);
        unawaited(ref.read(errorReporterProvider).report(error, stackTrace));
      }
    }
  }

  /// Copies the library into [source], then makes it the chosen one, so
  /// nothing is lost (PRD 7.8). Drive asks for access first, so call this
  /// from a tap.
  Future<void> switchTo(SyncSource source) async {
    if (source == .drive) await ref.read(driveAccessProvider).request();
    _replayNext = true;
    await ref.read(syncSourceControllerProvider.notifier).choose(source);
  }

  /// Asks Google again for Drive access, after "Sign in again", then syncs.
  Future<void> signInAgain() async {
    await ref.read(driveAccessProvider).request();
    await sync();
  }

  /// Whether [error] means the device is offline rather than broken.
  static bool _isOffline(Object error) {
    final text = error.toString();
    return text.contains('SocketException') ||
        text.contains('ClientException') ||
        text.contains('unavailable') ||
        text.contains('network');
  }
}
