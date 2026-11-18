import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:units/units.dart';

import '../../helpers/helpers.dart';

void main() {
  group(MeasuringGuide, () {
    testWidgets('joins the tools with plus signs', (tester) async {
      await tester.pumpDesignSystem(
        MeasuringGuide(
          tools: [
            (quantity: Quantity(1, 2), unit: 'cup'),
            (quantity: Quantity(1, 4), unit: 'cup'),
            (quantity: Quantity.one, unit: 'Tbsp'),
          ],
        ),
      );

      expect(find.text('½\u00A0cup'), findsOneWidget);
      expect(find.text('¼\u00A0cup'), findsOneWidget);
      expect(find.text('1\u00A0Tbsp'), findsOneWidget);
      expect(find.text('+'), findsNWidgets(2));
    });

    testWidgets('shows one tool without a plus sign', (tester) async {
      await tester.pumpDesignSystem(
        const MeasuringGuide(tools: [(quantity: Quantity.one, unit: 'cup')]),
      );

      expect(find.text('1\u00A0cup'), findsOneWidget);
      expect(find.text('+'), findsNothing);
    });

    testWidgets('says what the tools are for before them', (tester) async {
      await tester.pumpDesignSystem(
        const MeasuringGuide(
          label: 'Use',
          tools: [(quantity: Quantity.one, unit: 'cup')],
        ),
      );

      expect(
        tester.getTopRight(find.text('Use')).dx,
        lessThan(tester.getTopLeft(find.text('1\u00A0cup')).dx),
      );
    });

    testWidgets('takes the cooking style', (tester) async {
      await tester.pumpDesignSystem(
        Builder(
          builder: (context) => MeasuringGuide(
            tools: const [(quantity: Quantity.one, unit: 'cup')],
            style: context.appText.cookingIngredient,
          ),
        ),
      );
      expect(
        tester.widget<Text>(find.text('1\u00A0cup')).style!.fontSize,
        AppTypography.standard.cookingIngredient.fontSize,
      );
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await tester.expectMeetsGuidelines(
        MeasuringGuide(
          tools: [
            (quantity: Quantity(1, 2), unit: 'cup'),
            (quantity: Quantity(1, 4), unit: 'cup'),
          ],
        ),
      );
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'measuring_guide',
      width: 240,
      scenarios: {
        'two tools': MeasuringGuide(
          tools: [
            (quantity: Quantity(1, 2), unit: 'cup'),
            (quantity: Quantity(1, 4), unit: 'cup'),
          ],
        ),
        'wraps': MeasuringGuide(
          tools: [
            (quantity: Quantity.one, unit: 'cup'),
            (quantity: Quantity(1, 3), unit: 'cup'),
            (quantity: Quantity.one, unit: 'Tbsp'),
            (quantity: Quantity(1, 2), unit: 'tsp'),
          ],
        ),
        'labeled': MeasuringGuide(
          label: 'Use',
          tools: [(quantity: Quantity(1, 2), unit: 'Tbsp')],
        ),
        'cooking': Builder(
          builder: (context) => MeasuringGuide(
            tools: [
              (quantity: Quantity.one, unit: 'Tbsp'),
              (quantity: Quantity(2), unit: 'tsp'),
            ],
            style: context.appText.cookingIngredient,
          ),
        ),
      },
    );
  });
}
