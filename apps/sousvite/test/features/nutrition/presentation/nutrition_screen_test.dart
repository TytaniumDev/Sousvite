import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/nutrition/nutrition.dart';
import 'package:sousvite/features/nutrition/presentation/nutrient_table.dart';

import '../../../helpers/helpers.dart';
import '../fakes.dart';
import 'nutrition_harness.dart';

typedef _F = NutritionFixtures;
typedef _H = NutritionHarness;

void main() {
  final location = NutritionRoutes.location(_F.recipeId);

  Future<NutritionHarness> open(
    WidgetTester tester, {
    void Function(NutritionHarness harness)? before,
  }) async {
    tester.view
      ..physicalSize = const Size(800, 2400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final harness = NutritionHarness();
    await harness.seed();
    before?.call(harness);
    await harness.pump(tester, location: location);
    return harness;
  }

  NutritionMatch? matchOf(NutritionHarness harness, IngredientLineId line) =>
      harness.foods.matches.values
          .where((match) => match.ingredientLineId == line)
          .firstOrNull;

  group('NutritionScreen', () {
    testWidgets('lists every nutrient, nested under its parent', (
      tester,
    ) async {
      await open(tester);

      expect(find.byType(NutrientTable), findsOneWidget);
      expect(find.text('Saturated fat'), findsOneWidget);
      expect(find.text('Vitamin C'), findsOneWidget);
      expect(find.textContaining('0.5'), findsOneWidget);
    });

    testWidgets('remembers a new serving size', (tester) async {
      final harness = await open(tester);

      await tester.tap(find.byTooltip('More servings'));
      await tester.pumpAndSettle();

      expect(harness.prefs.prefs[_F.recipeId]!.servings, Quantity(5));
      expect(find.text('Per serving (1 of 5)'), findsOneWidget);
    });

    testWidgets('shows each match and where it came from', (tester) async {
      await open(tester);

      expect(find.text('usda-oats · 100 g'), findsOneWidget);
      expect(find.text('USDA'), findsOneWidget);
      expect(find.text('Not matched'), findsOneWidget);
      expect(find.text('Not counted in the totals'), findsOneWidget);
    });

    testWidgets('shows an empty state with no ingredients', (tester) async {
      tester.view
        ..physicalSize = const Size(800, 2400)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final harness = NutritionHarness();
      await harness.recipes.saveRecipe(_F.recipe());
      await harness.pump(tester, location: location);

      expect(find.text('No ingredients yet'), findsOneWidget);
    });

    testWidgets('changing one weight rebuilds only that line', (tester) async {
      final harness = await open(tester);
      final builds = BuildCounter.start()..reset();

      await harness.foods.saveMatch(
        matchOf(harness, _H.oats)!.copyWith(gramWeight: 50),
      );
      await tester.pumpAndSettle();

      expect(find.text('usda-oats · 50 g'), findsOneWidget);
      expect(builds.ofKey(const ValueKey(_H.oats)), 1);
      expect(builds.ofKey(const ValueKey(_H.milk)), 0);
    });

    testWidgets('matches a line to a food, working out its weight', (
      tester,
    ) async {
      final harness = await open(
        tester,
        before: (harness) {
          final milk = _F.food('usda-milk');
          harness.foods.addFood(
            milk,
            portions: [
              FoodPortion(
                id: const FoodPortionId('cup'),
                foodId: milk.id,
                amount: Quantity.one,
                unit: Unit.cup,
                gramWeight: 244,
              ),
            ],
          );
          harness.foods.searchResults = [milk];
        },
      );

      await tester.tap(find.text('milk'));
      await tester.pumpAndSettle();
      expect(find.text('Change match'), findsOneWidget);

      await tester.tap(find.text('usda-milk'));
      await tester.pumpAndSettle();

      final match = matchOf(harness, _H.milk)!;
      expect(match.foodId, const FoodId('usda-milk'));
      expect(match.gramWeight, 244);
      expect(match.userConfirmed, isTrue);
      expect(find.text('Edited'), findsOneWidget);
    });

    testWidgets('asks for grams when the weight is unknown', (tester) async {
      final harness = await open(
        tester,
        before: (harness) {
          harness.online = [
            (
              food: _F.food('off-milk', source: NutritionSource.openFoodFacts),
              nutrients: const [],
              portions: const [],
            ),
          ];
        },
      );

      await tester.tap(find.text('milk'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('off-milk'));
      await tester.pumpAndSettle();
      expect(find.text('Enter the weight in grams'), findsOneWidget);
      expect(matchOf(harness, _H.milk), isNull);

      await tester.enterText(find.widgetWithText(TextField, 'Weight'), '250');
      await tester.pump();
      expect(find.text('Enter the weight in grams'), findsNothing);
      await tester.tap(find.text('off-milk'));
      await tester.pumpAndSettle();

      expect(matchOf(harness, _H.milk)!.gramWeight, 250);
      expect(harness.foods.foods, contains(const FoodId('off-milk')));
    });

    testWidgets('searches for what the user types', (tester) async {
      final harness = await open(tester);
      harness.foods.searchResults = const [];

      await tester.tap(find.text('milk'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Search foods'),
        'oat milk',
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('No foods found'), findsOneWidget);
    });

    testWidgets('corrects a weight', (tester) async {
      final harness = await open(tester);

      await tester.tap(find.text('oats'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Weight'), 'lots');
      await tester.tap(find.text('Save weight'));
      await tester.pumpAndSettle();
      expect(find.text('Enter the weight in grams'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Weight'), '80');
      await tester.tap(find.text('Save weight'));
      await tester.pumpAndSettle();

      expect(matchOf(harness, _H.oats)!.gramWeight, 80);
      expect(find.text('Change match'), findsNothing);
    });

    testWidgets('leaves a line unmatched', (tester) async {
      final harness = await open(tester);

      await tester.tap(find.text('oats'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave unmatched'));
      await tester.pumpAndSettle();

      expect(matchOf(harness, _H.oats), isNull);
      expect(find.text('Excludes 2 unmatched ingredients'), findsOneWidget);
    });
  });
}
