import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sousvite/app/providers/database.dart';
import 'package:sousvite/app/services/auth_service.dart';
import 'package:sousvite/app/services/sharing_service.dart';
import 'package:sousvite/features/account/account.dart';
import 'package:sousvite/features/account/sync/application/shared_spaces.dart';
import 'package:sousvite/features/account/sync/application/sync_transport.dart';
import 'package:sousvite/features/cooking/application/screen_awake.dart';
import 'package:sousvite/features/import/application/recipe_importers.dart';
import 'package:sousvite/features/import/data/page_url_importer.dart';
import 'package:sync/sync.dart';
import 'package:uuid/uuid.dart';

import 'e2e_auth.dart';
import 'e2e_cloud.dart';
import 'e2e_database.dart';
import 'recipe_pages.dart';

/// One phone or browser in an end-to-end test: the real app's providers
/// with its own database, signed in as [user], syncing through [cloud]
/// instead of Firebase.
class E2eDevice(
  /// Names the device's database, so devices never share one.
  final String name, {
  required final E2eCloud cloud,
  required final AuthUser user,
}) {
  /// Whether the device reaches the cloud. Syncing while offline fails the
  /// way a dropped connection does.
  bool online = true;

  /// The device's providers.
  late final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWith((ref) {
        final database = openE2eDatabase(name);
        ref.onDispose(database.close);
        return database;
      }),
      authServiceProvider.overrideWithValue(E2eAuth(user)),
      sharingServiceProvider.overrideWithValue(cloud.sharingFor(user)),
      syncTransportProvider.overrideWith(
        (ref) => (
          spaceId: privateSpaceId,
          transport: _transport(cloud.privateSpace(user.id)),
          key: 'e2e:private',
          photos: cloud.photos('u_${user.id}'),
        ),
      ),
      sharedSpaceMembershipsProvider.overrideWith(
        (ref) => cloud.sharedSpaceIdsOf(user.id),
      ),
      sharedSyncTransportsProvider.overrideWith(
        (ref) => [
          for (final id in ref.watch(sharedSpaceIdsProvider))
            (
              spaceId: id,
              transport: _transport(cloud.space(id)),
              key: 'e2e:$id',
              photos: cloud.photos(id),
            ),
        ],
      ),
      // `flutter test -d flutter-tester` on Linux has no wake lock service.
      // Run there with --dart-define=E2E_NO_WAKELOCK=true; web and phones
      // use the real one.
      if (const bool.fromEnvironment('E2E_NO_WAKELOCK'))
        screenAwakeProvider.overrideWithValue(const _NoScreenAwake()),
      urlImporterProvider.overrideWithValue(
        PageUrlImporter(
          recipePageFetcher,
          newId: const Uuid().v4,
          // The page has no photo.
          importPhoto: (_) async => null,
        ),
      ),
    ],
  );

  SyncTransport _transport(InMemorySyncSpace space) =>
      _Switchable(InMemoryTransport(space), () => online);

  /// Opens the database and starts syncing, as `bootstrap` does.
  Future<void> start() async {
    await container.read(changeRecorderProvider.future);
    // Listened to first: the app listens to it from the first frame, and
    // reading it alone doesn't keep the stream running.
    container.listen(authUserProvider, (_, _) {});
    await container.read(authUserProvider.future);
    container.listen(syncControllerProvider, (_, _) {});
  }

  /// Syncs now, and waits for it.
  Future<void> sync() => container.read(syncControllerProvider.notifier).sync();

  /// Closes the device's providers and database.
  void dispose() => container.dispose();
}

class const _NoScreenAwake() implements ScreenAwake {
  @override
  Future<void> keepOn() async {}

  @override
  Future<void> release() async {}
}

/// A transport that fails like a dropped connection while [_online] says
/// the device is offline.
class _Switchable(final SyncTransport _inner, final bool Function() _online)
    implements SyncTransport {
  void _check() {
    if (!_online()) throw Exception('network unavailable');
  }

  @override
  Future<void> push(List<Change> changes) async {
    _check();
    await _inner.push(changes);
  }

  @override
  Stream<PulledBatch> pull({SyncCursor? since}) async* {
    _check();
    yield* _inner.pull(since: since);
  }

  @override
  Future<void> writeSnapshot(Snapshot snapshot) async {
    _check();
    await _inner.writeSnapshot(snapshot);
  }
}
