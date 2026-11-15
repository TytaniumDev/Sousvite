import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  const labels = {
    MatchStatus.usda: 'USDA',
    MatchStatus.openFoodFacts: 'Open Food Facts',
    MatchStatus.edited: 'Edited',
    MatchStatus.notMatched: 'Not matched',
  };

  Color fillOf(WidgetTester tester) =>
      (tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byType(MatchStatusChip),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration)
          .color!;

  group(MatchStatusChip, () {
    testWidgets('pairs every status with an icon and its word', (tester) async {
      for (final MapEntry(key: status, value: label) in labels.entries) {
        await tester.pumpDesignSystem(
          MatchStatusChip(status: status, label: label),
        );
        expect(find.text(label), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
      }
    });

    testWidgets('marks a missing match as a warning, not an error', (
      tester,
    ) async {
      await tester.pumpDesignSystem(
        const MatchStatusChip(status: .notMatched, label: 'Not matched'),
      );

      expect(fillOf(tester), AppColors.light.warningContainer);
      expect(
        tester.widget<Icon>(find.byType(Icon)).icon,
        Symbols.warning_rounded,
      );
    });

    testWidgets('keeps sources neutral and edits sage', (tester) async {
      await tester.pumpDesignSystem(
        const MatchStatusChip(status: .usda, label: 'USDA'),
      );
      expect(fillOf(tester), AppColorSchemes.light.surfaceContainerHigh);

      await tester.pumpDesignSystem(
        const MatchStatusChip(status: .edited, label: 'Edited'),
      );
      expect(fillOf(tester), AppColorSchemes.light.secondaryContainer);
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      for (final MapEntry(key: status, value: label) in labels.entries) {
        await tester.expectMeetsGuidelines(
          MatchStatusChip(status: status, label: label),
        );
      }
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'match_status_chip',
      scenarios: {
        for (final MapEntry(key: status, value: label) in labels.entries)
          status.name: MatchStatusChip(status: status, label: label),
      },
    );
  });
}
