import 'package:clock/clock.dart';
import 'package:data/data.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/database.dart';
import 'package:sousvite/app/services/auth_service.dart';
import 'package:sousvite/app/services/firebase.dart';
import 'package:sousvite/features/account/sync/application/shared_spaces.dart';
import 'package:sousvite/features/account/sync/application/sign_in_callout.dart';
import 'package:sousvite/features/account/sync/application/sync_source.dart';
import 'package:sousvite/features/account/sync/application/sync_source_controller.dart';
import 'package:sousvite/features/account/sync/application/sync_transport.dart';
import 'package:sync/sync.dart';

import '../../fakes.dart';
import '../fakes.dart';

const appleUser = AuthUser(
  id: 'u2',
  displayName: 'Sam',
  email: 'sam@example.com',
  method: SignInMethod.apple,
);

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  ProviderContainer container({
    bool firebase = true,
    AuthUser? user,
    List<String> sharedIds = const [],
  }) {
    final created = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        firebaseAppProvider.overrideWithValue(
          firebase ? FakeFirebaseApp() : null,
        ),
        cloudSpacesProvider.overrideWithValue(firebase ? fakeCloud : null),
        authServiceProvider.overrideWithValue(FakeAuthService(user)),
        sharedSpaceIdsProvider.overrideWithValue(sharedIds),
      ],
    );
    addTearDown(created.dispose);
    return created;
  }

  group(SyncSourceController, () {
    test('starts on Sousvite cloud', () async {
      expect(
        await container().read(syncSourceControllerProvider.future),
        SyncSource.cloud,
      );
    });

    test('remembers the choice on this device', () async {
      await container()
          .read(syncSourceControllerProvider.notifier)
          .choose(.drive);

      expect(
        await container().read(syncSourceControllerProvider.future),
        SyncSource.drive,
      );
    });
  });

  group(SignInCalloutDismissal, () {
    Future<bool> visible(ProviderContainer container) async {
      container.listen(signInCalloutVisibleProvider, (_, _) {});
      await container.read(signInCalloutDismissalProvider.future);
      await pumpEventQueue();
      final shown = container.read(signInCalloutVisibleProvider);
      return shown;
    }

    test('shows the card to signed-out users', () async {
      expect(await visible(container()), isTrue);
    });

    test('never shows it without Firebase or when signed in', () async {
      expect(await visible(container(firebase: false)), isFalse);
      expect(await visible(container(user: tyler)), isFalse);
    });

    test('"Not now" hides it for 30 days, across restarts', () async {
      final start = DateTime.utc(2026, 11, 16);
      await withClock(Clock.fixed(start), () async {
        final first = container();
        await first.read(signInCalloutDismissalProvider.future);
        await first.read(signInCalloutDismissalProvider.notifier).dismiss();
        expect(await visible(first), isFalse);
        expect(await visible(container()), isFalse);
      });

      final later = start.add(SignInCalloutDismissal.hiddenFor);
      await withClock(Clock.fixed(later), () async {
        expect(await visible(container()), isTrue);
      });
    });
  });

  group('sync transports', () {
    test('are off without Firebase or a user', () async {
      final offline = container(firebase: false, user: tyler);
      final signedOut = container();
      for (final c in [offline, signedOut]) {
        await c.read(syncSourceControllerProvider.future);
        await pumpEventQueue();
        expect(c.read(syncTransportProvider), isNull);
        expect(c.read(sharedSyncTransportsProvider), isEmpty);
      }
    });

    test('use Drive when chosen by a Google user', () async {
      final c = container(user: tyler);
      await c.read(changeRecorderProvider.future);
      await c.read(syncSourceControllerProvider.notifier).choose(.drive);
      c.listen(syncTransportProvider, (_, _) {});
      await pumpEventQueue();

      final chosen = c.read(syncTransportProvider);
      expect(chosen?.transport, isA<DriveTransport>());
      expect(chosen?.key, 'drive:${tyler.id}');
      expect(c.read(syncLocalStoreProvider), isA<DriftLocalStore>());
    });

    test('never use Drive for an Apple account', () async {
      final c = container(user: appleUser);
      await c.read(changeRecorderProvider.future);
      await c.read(syncSourceControllerProvider.notifier).choose(.drive);
      c.listen(syncTransportProvider, (_, _) {});
      await pumpEventQueue();

      expect(c.read(syncTransportProvider), isNull);
    });

    test('use Sousvite cloud for the library and every joint share', () async {
      final c = container(user: tyler, sharedIds: ['s_1']);
      await c.read(syncSourceControllerProvider.future);
      c
        ..listen(syncTransportProvider, (_, _) {})
        ..listen(sharedSyncTransportsProvider, (_, _) {});
      await pumpEventQueue();

      expect(c.read(syncTransportProvider)?.key, 'firestore:u_${tyler.id}');
      final shared = c.read(sharedSyncTransportsProvider).single;
      expect(shared.spaceId, 's_1');
      expect(shared.key, 'firestore:s_1');
      expect(shared.transport, isA<FirestoreTransport>());
    });

    test('no joint shares until sharing fills them in', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(sharedSpaceIdsProvider), isEmpty);
    });
  });
}
