import 'package:domain/domain.dart';
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

    testWidgets('fixes all the ingredients that clearly fit a food', (
      tester,
    ) async {
      final harness = NutritionHarness();
      await harness.seed();
      final milk = NutritionFixtures.food('usda-milk')
          .copyWith(name: 'Milk, whole');
      harness.foods.addFood(
        milk,
        portions: [
          FoodPortion(
            id: const FoodPortionId('usda-milk:cup'),
            foodId: milk.id,
            amount: Quantity.one,
            gramWeight: 244,
            unit: Unit.cup,
            description: '1 cup',
          ),
        ],
      );
      await harness.pump(tester);

      await tester.tap(find.text('Fix all'));
      await tester.pumpAndSettle();

      expect(find.text('Matched 1 ingredient.'), findsOneWidget);
      expect(find.textContaining('unmatched'), findsNothing);
      final match = harness.foods.matches.values.firstWhere(
        (m) => m.ingredientLineId == NutritionHarness.milk,
      );
      expect(match.foodId, milk.id);
      expect(match.gramWeight, 244);
    });

    testWidgets('says what it could not fix', (tester) async {
      final harness = NutritionHarness();
      await harness.seed();
      await harness.pump(tester);

      await tester.tap(find.text('Fix all'));
      await tester.pumpAndSettle();

      expect(
        find.text('No clear matches found. 1 still needs a match.'),
        findsOneWidget,
      );
      expect(find.text('Excludes 1 unmatched ingredient'), findsOneWidget);
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
