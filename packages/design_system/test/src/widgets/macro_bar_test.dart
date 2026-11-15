import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  group(MacroBar, () {
    testWidgets('fills the width at a fixed height', (tester) async {
      await tester.pumpDesignSystem(
        const SizedBox(
          width: 200,
          child: MacroBar(protein: 30, carbs: 40, fat: 10),
        ),
      );

      expect(tester.getSize(find.byType(MacroBar)), const Size(200, 8));
    });

    testWidgets('is hidden from screen readers', (tester) async {
      await tester.pumpDesignSystem(
        const MacroBar(protein: 30, carbs: 40, fat: 10),
      );

      expect(
        find.descendant(
          of: find.byType(MacroBar),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'macro_bar',
      width: 240,
      scenarios: {
        'balanced': const MacroBar(protein: 30, carbs: 40, fat: 10),
        'protein heavy': const MacroBar(protein: 60, carbs: 5, fat: 4),
        'no fat': const MacroBar(protein: 10, carbs: 50, fat: 0),
        'empty': const MacroBar(protein: 0, carbs: 0, fat: 0),
      },
    );
  });
}
