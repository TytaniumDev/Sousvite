import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/services/auth_service.dart';
import 'package:sousvite/features/account/sync/application/sync_controller.dart';
import 'package:sousvite/features/account/sync/application/sync_source.dart';
import 'package:sousvite/features/account/sync/application/sync_source_controller.dart';
import 'package:sousvite/features/account/sync/application/sync_state.dart';
import 'package:sousvite/features/account/sync/presentation/sync_source_setting.dart';

import '../../../../helpers/helpers.dart';
import '../../fakes.dart';
import '../fake_sync_controller.dart';

class _FixedSource(final SyncSource source) extends SyncSourceController {
  @override
  Future<SyncSource> build() async => source;
}

void main() {
  Future<SyncRequests> pump(
    WidgetTester tester, {
    AuthUser? user = tyler,
    SyncState state = const SyncState(phase: .synced),
  }) async {
    final requests = SyncRequests();
    await tester.pumpApp(
      const Scaffold(body: SyncSourceSetting()),
      overrides: [
        authServiceProvider.overrideWithValue(FakeAuthService(user)),
        syncControllerProvider.overrideWith(
          () => FakeSyncController(state, requests),
        ),
        syncSourceControllerProvider.overrideWith(() => _FixedSource(.cloud)),
      ],
    );
    await tester.pump();
    return requests;
  }

  group(SyncSourceSetting, () {
    testWidgets('is hidden while signed out', (tester) async {
      await pump(tester, user: null);

      expect(find.byType(SegmentedButton<SyncSource>), findsNothing);
    });

    testWidgets('switches to Drive for a Google user', (tester) async {
      final requests = await pump(tester);

      expect(find.text('Beta'), findsOneWidget);
      await tester.tap(find.text('Google Drive'));
      await tester.pump();

      expect(requests.switches, [SyncSource.drive]);
    });

    testWidgets('says so when a switch fails', (tester) async {
      final requests = await pump(tester)
        ..switchError = Exception('no');

      await tester.tap(find.text('Google Drive'));
      await tester.pump();
      await tester.pump();

      expect(requests.switches, [SyncSource.drive]);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('keeps Drive for Google accounts', (tester) async {
      await pump(
        tester,
        user: const AuthUser(
          id: 'u2',
          displayName: 'Sam',
          email: 'sam@example.com',
          method: SignInMethod.apple,
        ),
      );

      final segments = tester
          .widget<SegmentedButton<SyncSource>>(
            find.byType(SegmentedButton<SyncSource>),
          )
          .segments;
      expect(segments.last.enabled, isFalse);
    });

    testWidgets('shows when the last sync finished', (tester) async {
      await pump(
        tester,
        state: SyncState(
          phase: .synced,
          lastSyncedAt: DateTime(2026, 11, 16, 9, 30),
        ),
      );

      expect(find.textContaining('9:30'), findsOneWidget);
    });
  });
}
