import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  group(NutrientRow, () {
    testWidgets('shows the label and the rounded value with its unit', (
      tester,
    ) async {
      await tester.pumpDesignSystem(
        const NutrientRow(label: 'Fat', value: 4.46, unit: 'g'),
      );

      expect(find.text('Fat'), findsOneWidget);
      expect(find.text('4.5 g'), findsOneWidget);
    });

    testWidgets('rounds milligrams to whole numbers', (tester) async {
      await tester.pumpDesignSystem(
        const NutrientRow(
          label: 'Sodium',
          value: 482.6,
          unit: 'mg',
          precision: NutrientPrecision.whole,
        ),
      );

      expect(find.text('483 mg'), findsOneWidget);
    });

    testWidgets('indents nested nutrients and quiets their label', (
      tester,
    ) async {
      await tester.pumpDesignSystem(
        const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NutrientRow(label: 'Fat', value: 12, unit: 'g'),
            NutrientRow(label: 'Saturated fat', value: 3, unit: 'g', indent: 1),
          ],
        ),
      );

      final top = tester.getTopLeft(find.text('Fat'));
      final nested = tester.getTopLeft(find.text('Saturated fat'));
      expect(nested.dx - top.dx, AppSpacing.space4);
      expect(
        tester.widget<Text>(find.text('Saturated fat')).style?.color,
        AppColorSchemes.light.onSurfaceVariant,
      );
    });

    testWidgets('reads as one item', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpDesignSystem(
        const NutrientRow(label: 'Fat', value: 12, unit: 'g'),
      );

      expect(find.bySemanticsLabel(RegExp(r'Fat\n12.g')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await tester.expectMeetsGuidelines(
        const NutrientRow(label: 'Fat', value: 12, unit: 'g'),
      );
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'nutrient_row',
      width: 320,
      scenarios: {
        'table': const CompactDensity(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NutrientRow(
                label: 'Calories',
                value: 523.6,
                unit: 'kcal',
                precision: NutrientPrecision.whole,
              ),
              NutrientRow(label: 'Fat', value: 12.4, unit: 'g'),
              NutrientRow(
                label: 'Saturated fat',
                value: 3.25,
                unit: 'g',
                indent: 1,
              ),
              NutrientRow(
                label: 'Sodium',
                value: 482.6,
                unit: 'mg',
                precision: NutrientPrecision.whole,
              ),
            ],
          ),
        ),
      },
    );
  });
}
