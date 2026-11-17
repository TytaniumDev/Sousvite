import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/account/sync/application/sync_controller.dart';
import 'package:sousvite/features/account/sync/application/sync_state.dart';
import 'package:sousvite/features/account/sync/presentation/sync_status_button.dart';

import '../../../../helpers/helpers.dart';
import '../fake_sync_controller.dart';

void main() {
  Future<SyncRequests> pump(WidgetTester tester, SyncPhase phase) async {
    final requests = SyncRequests();
    await tester.pumpApp(
      const Scaffold(body: SyncStatusButton()),
      overrides: [
        syncControllerProvider.overrideWith(
          () => FakeSyncController(SyncState(phase: phase), requests),
        ),
      ],
    );
    return requests;
  }

  group(SyncStatusButton, () {
    testWidgets('is hidden while sync is off', (tester) async {
      await pump(tester, .off);

      expect(find.byType(SyncStatusIcon), findsNothing);
    });

    testWidgets('shows each phase with its own label', (tester) async {
      for (final phase in [
        SyncPhase.syncing,
        SyncPhase.synced,
        SyncPhase.offline,
        SyncPhase.error,
      ]) {
        await pump(tester, phase);
        expect(find.byType(SyncStatusIcon), findsOneWidget);
        expect(find.byType(InkResponse), findsNothing);
      }
    });

    testWidgets('asks Google again when tapped after Drive access ends', (
      tester,
    ) async {
      final requests = await pump(tester, .signInAgain);

      await tester.tap(find.byType(SyncStatusIcon));
      await tester.pump();

      expect(requests.signInAgain, 1);
    });
  });
}
