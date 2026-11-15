import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  const labels = MacroLabels(
    calories: 'Calories',
    protein: 'Protein',
    carbs: 'Carbs',
    fat: 'Fat',
    grams: 'g',
  );
  const summary = MacroSummary(
    calories: 523.6,
    protein: 31.2,
    carbs: 48.7,
    fat: 4.46,
    basisLabel: 'Per serving (1 of 4)',
    labels: labels,
  );

  group(MacroSummary, () {
    testWidgets('shows the basis, calories, and rounded macros', (
      tester,
    ) async {
      await tester.pumpDesignSystem(summary);

      expect(find.text('Per serving (1 of 4)'), findsOneWidget);
      expect(find.text('524'), findsOneWidget);
      expect(find.text('Calories'), findsOneWidget);
      expect(find.text('31 g'), findsOneWidget);
      expect(find.text('49 g'), findsOneWidget);
      expect(find.text('4.5 g'), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);
      expect(find.byType(MacroBar), findsOneWidget);
    });

    testWidgets('colors each macro and reads it with its name', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpDesignSystem(summary);

      final protein = tester.widget<Text>(find.text('31 g'));
      expect(protein.style?.color, AppColors.light.protein);
      expect(find.bySemanticsLabel(RegExp(r'31.g\nProtein')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'524\nCalories')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await tester.expectMeetsGuidelines(summary);
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'macro_summary',
      width: 320,
      scenarios: {
        'per serving': summary,
        'whole batch': const MacroSummary(
          calories: 2094,
          protein: 124.8,
          carbs: 194.8,
          fat: 17.8,
          basisLabel: 'Whole batch',
          labels: labels,
        ),
      },
    );
  });
}
