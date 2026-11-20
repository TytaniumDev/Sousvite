import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  const labels = {
    SyncIconStatus.synced: 'Synced',
    SyncIconStatus.syncing: 'Syncing',
    SyncIconStatus.offline: 'Offline',
    SyncIconStatus.error: "Couldn't sync",
  };
  const scheme = AppColorSchemes.light;

  /// [child] with animations turned off, as under reduced motion.
  Widget stillMotion(Widget child) => Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child,
    ),
  );

  Animation<double> turnsOf(WidgetTester tester) => tester
      .widget<RotationTransition>(
        find.descendant(
          of: find.byType(SyncStatusIcon),
          matching: find.byType(RotationTransition),
        ),
      )
      .turns;

  Icon iconOf(WidgetTester tester) => tester.widget<Icon>(find.byType(Icon));

  group(SyncStatusIcon, () {
    testWidgets('shows a quiet icon for synced and offline', (tester) async {
      await tester.pumpDesignSystem(
        const SyncStatusIcon(status: .synced, label: 'Synced'),
      );
      expect(iconOf(tester).icon, Symbols.cloud_done_rounded);
      expect(iconOf(tester).color, scheme.onSurfaceVariant);

      await tester.pumpDesignSystem(
        const SyncStatusIcon(status: .offline, label: 'Offline'),
      );
      expect(iconOf(tester).icon, Symbols.cloud_off_rounded);
      expect(iconOf(tester).color, scheme.onSurfaceVariant);
    });

    testWidgets('uses the error color only for an error', (tester) async {
      await tester.pumpDesignSystem(
        const SyncStatusIcon(status: .error, label: "Couldn't sync"),
      );

      expect(iconOf(tester).icon, Symbols.sync_problem_rounded);
      expect(iconOf(tester).color, scheme.error);
    });

    testWidgets('says its state in a tooltip', (tester) async {
      await tester.pumpDesignSystem(
        const SyncStatusIcon(status: .offline, label: 'Offline'),
      );

      expect(tester.widget<Tooltip>(find.byType(Tooltip)).message, 'Offline');
      expect(
        tester.getSize(find.byType(SyncStatusIcon)),
        const Size.square(SyncStatusIcon.size),
      );
    });

    testWidgets('turns counterclockwise, with the arrows, while syncing', (
      tester,
    ) async {
      await tester.pumpDesignSystem(
        const SyncStatusIcon(status: .syncing, label: 'Syncing'),
      );
      final turns = turnsOf(tester);
      final start = turns.value;

      await tester.pump(const Duration(milliseconds: 500));

      expect(turns.value, lessThan(start));
      expect(iconOf(tester).icon, Symbols.sync_rounded);
    });

    testWidgets('holds still under reduced motion', (tester) async {
      await tester.pumpDesignSystem(
        stillMotion(const SyncStatusIcon(status: .syncing, label: 'Syncing')),
      );
      final turns = turnsOf(tester);

      await tester.pump(const Duration(milliseconds: 500));

      expect(turns.value, 0);
    });

    testWidgets('starts turning when reduced motion is turned off', (
      tester,
    ) async {
      var still = true;
      late StateSetter setState;
      await tester.pumpDesignSystem(
        StatefulBuilder(
          builder: (context, setter) {
            setState = setter;
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: still),
              child: const SyncStatusIcon(status: .syncing, label: 'Syncing'),
            );
          },
        ),
      );

      setState(() => still = false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final turns = turnsOf(tester);
      expect(turns.value, lessThan(0));
    });

    testWidgets('shows only the state without onTap', (tester) async {
      await tester.pumpDesignSystem(
        SyncStatusIcon(status: .synced, label: labels[SyncIconStatus.synced]!),
      );

      expect(find.byType(PaddedInkWell), findsNothing);
      expect(
        tester.getSize(find.byType(SyncStatusIcon)),
        const Size.square(SyncStatusIcon.size),
      );
    });

    testWidgets('is a round button with onTap, the icon centered in ink', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpDesignSystem(
        SyncStatusIcon(
          status: .error,
          label: 'Sign in again',
          onTap: () => taps++,
        ),
      );

      final ink = tester.getRect(find.byType(InkWell));
      final glyph = tester.getRect(find.byType(Icon));
      expect(ink.size, const Size.square(SyncStatusIcon.size));
      expect(glyph.center, ink.center);
      expect(
        tester.widget<InkWell>(find.byType(InkWell)).customBorder,
        const CircleBorder(),
      );
      expect(
        tester.getSemantics(find.byType(InkWell)),
        isSemantics(isButton: true, hasTapAction: true),
      );

      await tester.tap(find.byType(SyncStatusIcon));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      for (final MapEntry(key: status, value: label) in labels.entries) {
        await tester.expectMeetsGuidelines(
          stillMotion(SyncStatusIcon(status: status, label: label)),
        );
      }
      await tester.expectMeetsGuidelines(
        SyncStatusIcon(status: .error, label: 'Sign in again', onTap: () {}),
      );
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'sync_status_icon',
      pumpBeforeTest: (tester) => tester.pump(),
      scenarios: {
        for (final MapEntry(key: status, value: label) in labels.entries)
          status.name: stillMotion(
            SyncStatusIcon(status: status, label: label),
          ),
      },
    );
  });
}
