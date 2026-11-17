import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/database.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/app/services/error_reporter.dart';
import 'package:sousvite/features/account/sync/application/sync_controller.dart';
import 'package:sousvite/features/account/sync/application/sync_source.dart';
import 'package:sousvite/features/account/sync/application/sync_source_controller.dart';
import 'package:sousvite/features/account/sync/application/sync_state.dart';
import 'package:sousvite/features/account/sync/application/sync_transport.dart';
import 'package:sousvite/features/account/sync/data/drive_access.dart';
import 'package:sync/sync.dart';

import '../fakes.dart';

/// One simulated device: its own database and providers, syncing through
/// [transport].
final class _Device(
  final SyncTransport? transport, {
  final List<SpaceTransport> shared = const [],
}) {
  final database = AppDatabase(NativeDatabase.memory());
  final reporter = RecordingReporter();
  final access = FakeDriveAccess();
  late final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      errorReporterProvider.overrideWithValue(reporter),
      driveAccessProvider.overrideWithValue(access),
      syncTransportProvider.overrideWithValue(switch (transport) {
        final transport? => (
          spaceId: privateSpaceId,
          transport: transport,
          key: 'memory',
        ),
        null => null,
      }),
      sharedSyncTransportsProvider.overrideWithValue(shared),
    ],
  );

  Future<SyncController> start() async {
    await container.read(changeRecorderProvider.future);
    container.listen(syncControllerProvider, (_, _) {});
    final controller = container.read(syncControllerProvider.notifier);
    await controller.sync();
    return controller;
  }

  SyncState get state => container.read(syncControllerProvider);

  Future<void> dispose() async {
    container.dispose();
    await database.close();
  }
}

Recipe _recipe(String id, String title) => Recipe(
  id: RecipeId(id),
  title: title,
  servings: Quantity(2),
  createdAt: DateTime.utc(2026, 11, 16),
  updatedAt: DateTime.utc(2026, 11, 16),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InMemorySyncSpace space;
  final devices = <_Device>[];

  _Device device([SyncTransport? transport]) {
    final created = _Device(transport ?? InMemoryTransport(space));
    devices.add(created);
    return created;
  }

  setUp(() => space = InMemorySyncSpace());

  tearDown(() async {
    for (final device in devices) {
      await device.dispose();
    }
    devices.clear();
  });

  group(SyncController, () {
    test('is off without a transport', () async {
      final phone = _Device(null);
      devices.add(phone);

      await phone.start();

      expect(phone.state.phase, SyncPhase.off);
    });

    test(
      'copies the library up on first sync and syncs it to others',
      () async {
        final phone = device();
        await phone.container.read(changeRecorderProvider.future);
        await phone.container
            .read(recipeRepositoryProvider)
            .saveRecipe(_recipe('r1', 'Soup'));

        await phone.start();
        expect(phone.state.phase, SyncPhase.synced);
        expect(phone.state.lastSyncedAt, isNotNull);
        expect(space.changes, isNotEmpty);
        expect(space.snapshot, isNotNull);

        final laptop = device();
        await laptop.start();
        final recipe = await laptop.container
            .read(recipeRepositoryProvider)
            .getRecipe(const RecipeId('r1'));
        expect(recipe?.title, 'Soup');
      },
    );

    test('syncs each joint share through its own transport', () async {
      final share = InMemorySyncSpace();
      final phone = _Device(
        null,
        shared: [
          (
            spaceId: 's_1',
            transport: InMemoryTransport(share),
            key: 'firestore:s_1',
          ),
        ],
      );
      devices.add(phone);

      await phone.start();

      expect(phone.state.phase, SyncPhase.synced);
      expect(share.snapshot, isNotNull);
    });

    test('a sync asked for while one runs runs once more after', () async {
      final phone = await device().start();

      await Future.wait([phone.sync(), phone.sync(), phone.sync()]);

      expect(devices.single.state.phase, SyncPhase.synced);
    });

    test('says when Drive needs the user again', () async {
      final phone = device(FailingTransport(const DriveSignInRequired()));

      await phone.start();

      expect(phone.state.phase, SyncPhase.signInAgain);
      expect(phone.reporter.errors, isEmpty);
    });

    test('treats a lost connection as offline, not an error', () async {
      final phone = device(
        FailingTransport(const SocketLikeException('SocketException')),
      );

      await phone.start();

      expect(phone.state.phase, SyncPhase.offline);
      expect(phone.reporter.errors, isEmpty);
    });

    test('reports other failures', () async {
      final phone = device(FailingTransport(const SocketLikeException('boom')));

      await phone.start();

      expect(phone.state.phase, SyncPhase.error);
      expect(phone.reporter.errors, isNotEmpty);
    });

    test('switching to Drive asks for access and copies everything', () async {
      final phone = device();
      final controller = await phone.start();

      await controller.switchTo(SyncSource.drive);

      expect(phone.access.requests, 1);
      expect(
        phone.container.read(syncSourceControllerProvider).value,
        SyncSource.drive,
      );
    });

    test('switching back to the cloud does not ask Google', () async {
      final phone = device();
      final controller = await phone.start();

      await controller.switchTo(SyncSource.cloud);

      expect(phone.access.requests, 0);
    });

    test('signing in again asks Google, then syncs', () async {
      final phone = device();
      final controller = await phone.start();

      await controller.signInAgain();

      expect(phone.access.requests, 1);
      expect(phone.state.phase, SyncPhase.synced);
    });
  });

  group(SyncState, () {
    test('keeps the last sync time across phases', () {
      final at = DateTime.utc(2026, 11, 16);
      final state = const SyncState(phase: .synced)
          .to(.synced, lastSyncedAt: at);

      expect(state.to(.syncing).lastSyncedAt, at);
      expect(state, SyncState(phase: .synced, lastSyncedAt: at));
      expect(
        state.hashCode,
        SyncState(phase: .synced, lastSyncedAt: at).hashCode,
      );
    });
  });

  group(SyncSource, () {
    test('round-trips through its stored name', () {
      for (final source in SyncSource.values) {
        expect(SyncSource.fromStoredName(source.storedName), source);
      }
      expect(SyncSource.fromStoredName(null), SyncSource.cloud);
    });
  });
}

/// An exception whose text says what kind of failure it is.
class const SocketLikeException(final String message) implements Exception {
  @override
  String toString() => message;
}
