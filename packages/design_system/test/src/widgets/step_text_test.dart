import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:units/units.dart';

import '../../helpers/helpers.dart';

void main() {
  final segments = <StepSegment>[
    const StepTextSegment('Whisk in '),
    StepAmountSegment(
      quantity: Quantity(3, 4),
      unit: 'cup',
      semanticsLabel: 'three quarters cup',
    ),
    const StepTextSegment(' sugar until smooth.'),
  ];

  TextSpan amountSpan(WidgetTester tester) {
    final text = tester.widget<Text>(find.byType(Text));
    return (text.textSpan! as TextSpan).children!
        .whereType<TextSpan>()
        .elementAt(1);
  }

  group(StepText, () {
    testWidgets('places amounts inline and reads them as words', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpDesignSystem(StepText(segments: segments));

      final text = tester.widget<Text>(find.byType(Text)).textSpan!;
      expect(
        text.toPlainText(includeSemanticsLabels: false),
        'Whisk in ¾\u00A0cup sugar until smooth.',
      );
      expect(
        find.bySemanticsLabel(RegExp('three quarters cup')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('colors amounts primary, highlighted only in the editor', (
      tester,
    ) async {
      await tester.pumpDesignSystem(StepText(segments: segments));
      var style = amountSpan(tester).style!;
      expect(style.color, AppColorSchemes.light.primary);
      expect(style.backgroundColor, isNull);
      expect(style.fontWeight, AppTypography.standard.amount.fontWeight);

      await tester.pumpDesignSystem(
        StepText(segments: segments, highlightAmounts: true),
      );
      style = amountSpan(tester).style!;
      expect(style.backgroundColor, AppColorSchemes.light.primaryContainer);
    });

    testWidgets('takes the cooking styles', (tester) async {
      await tester.pumpDesignSystem(
        Builder(
          builder: (context) => StepText(
            segments: segments,
            style: context.appText.cookingStep,
            amountStyle: context.appText.cookingAmount,
          ),
        ),
      );
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style, AppTypography.standard.cookingStep);
      expect(
        amountSpan(tester).style!.fontSize,
        AppTypography.standard.cookingAmount.fontSize,
      );
    });

    test('segments compare by value', () {
      expect(const StepTextSegment('a'), const StepTextSegment('a'));
      expect(
        const StepTextSegment('a').hashCode,
        const StepTextSegment('a').hashCode,
      );
      expect(const StepTextSegment('a'), isNot(const StepTextSegment('b')));
      StepAmountSegment amount({String unit = 'cup'}) =>
          StepAmountSegment(quantity: Quantity.one, unit: unit);
      expect(amount(), amount());
      expect(amount().hashCode, amount().hashCode);
      expect(amount(), isNot(amount(unit: 'Tbsp')));
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await tester.expectMeetsGuidelines(StepText(segments: segments));
      // primary on primary-container is checked in contrast_test.dart.
      await tester.expectMeetsGuidelines(
        StepText(segments: segments, highlightAmounts: true),
        textContrast: false,
      );
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'step_text',
      width: 320,
      scenarios: {
        'plain': StepText(segments: segments),
        'editor highlight': StepText(
          segments: segments,
          highlightAmounts: true,
        ),
        'cooking': Builder(
          builder: (context) => StepText(
            segments: segments,
            style: context.appText.cookingStep,
            amountStyle: context.appText.cookingAmount,
          ),
        ),
      },
    );
  });
}
