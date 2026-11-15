import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:units/units.dart';

import '../../helpers/helpers.dart';

void main() {
  final widget = AmountText(
    quantity: Quantity(3, 2),
    unit: 'cups',
    semanticsLabel: 'one and a half cups',
  );

  group(AmountText, () {
    testWidgets('writes the quantity with fraction glyphs and its unit', (
      tester,
    ) async {
      await tester.pumpDesignSystem(widget);

      expect(find.text('1 ½ cups'), findsOneWidget);
    });

    testWidgets('shows a bare count without a unit', (tester) async {
      await tester.pumpDesignSystem(AmountText(quantity: Quantity(2)));

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('reads the spoken label when given one', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpDesignSystem(widget);

      expect(find.bySemanticsLabel('one and a half cups'), findsOneWidget);

      await tester.pumpDesignSystem(
        AmountText(quantity: Quantity(1, 4), unit: 'tsp'),
      );
      expect(find.bySemanticsLabel('¼ tsp'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('uses the amount style unless given one', (tester) async {
      await tester.pumpDesignSystem(widget);
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style, AppTypography.standard.amount);

      const style = TextStyle(fontWeight: FontWeight.w700);
      await tester.pumpDesignSystem(
        AmountText(quantity: Quantity(2), unit: 'Tbsp', style: style),
      );
      expect(tester.widget<Text>(find.byType(Text)).style, style);
    });

    test('joins number and unit with a non-breaking space', () {
      expect(AmountText.textFor(Quantity(3, 4), 'cup'), '¾ cup');
      expect(AmountText.textFor(Quantity(3), null), '3');
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await tester.expectMeetsGuidelines(widget);
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'amount_text',
      scenarios: {
        'mixed number': widget,
        'cooking size': Builder(
          builder: (context) => AmountText(
            quantity: Quantity(3, 4),
            unit: 'cup',
            style: context.appText.cookingAmount,
          ),
        ),
      },
    );
  });
}
