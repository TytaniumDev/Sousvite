import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';
import 'nutrition_harness.dart';

// MacroSummary keeps a value and its unit together with a no-break space.
void main() {
  group('NutritionSummary', () {
    testWidgets('shows macros per serving, labeled with the servings', (
      tester,
    ) async {
      final harness = NutritionHarness();
      await harness.seed();
      await harness.pump(tester);

      expect(find.text('Per serving (1 of 4)'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('2.5\u00a0g'), findsOneWidget);
      expect(find.text('15\u00a0g'), findsOneWidget);
      expect(find.text('2\u00a0g'), findsOneWidget);
    });

    testWidgets('switches to the whole batch', (tester) async {
      final harness = NutritionHarness();
      await harness.seed();
      await harness.pump(tester);

      await tester.tap(find.text('Per batch'));
      await tester.pumpAndSettle();

      expect(find.text('Whole batch'), findsOneWidget);
      expect(find.text('400'), findsOneWidget);
      expect(find.text('60\u00a0g'), findsOneWidget);
    });

    testWidgets('counts unmatched ingredients and links to fix them', (
      tester,
    ) async {
      final harness = NutritionHarness();
      await harness.seed();
      await harness.pump(tester);

      expect(find.text('Excludes 1 unmatched ingredient'), findsOneWidget);
      await tester.tap(find.text('Fix'));
      await tester.pumpAndSettle();

      expect(find.text('Nutrients'), findsOneWidget);
      expect(find.text('Fix'), findsNothing);
    });

    testWidgets('says nothing when every ingredient is matched', (
      tester,
    ) async {
      final harness = NutritionHarness();
      await harness.seed();
      await harness.foods.saveMatch(
        NutritionFixtures.match('milk', 'usda-oats', 244),
      );
      await harness.pump(tester);

      expect(find.textContaining('unmatched'), findsNothing);
    });
  });
}
