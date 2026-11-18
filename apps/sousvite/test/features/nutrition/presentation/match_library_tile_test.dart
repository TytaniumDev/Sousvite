import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/nutrition/nutrition.dart';

import '../../../helpers/helpers.dart';
import '../fakes.dart';

typedef _F = NutritionFixtures;

void main() {
  group(MatchLibraryTile, () {
    testWidgets('matches every recipe and says how it went', (tester) async {
      final recipes = FakeRecipeRepository();
      final foods = FakeFoodRepository();
      const garlic = Food(
        id: FoodId('usda:garlic'),
        source: NutritionSource.usda,
        externalId: 'garlic',
        name: 'Garlic, raw',
      );
      foods.addFood(garlic);
      await recipes.saveRecipe(_F.recipe());
      await recipes.saveIngredientLine(
        _F
            .line('garlic', quantity: Quantity(10), unit: Unit.gram)
            .copyWith(name: 'garlic'),
      );
      await recipes.saveIngredientLine(_F.line('saffron'));

      await tester.pumpApp(
        const Scaffold(body: MatchLibraryTile()),
        overrides: [
          recipeRepositoryProvider.overrideWithValue(recipes),
          foodRepositoryProvider.overrideWithValue(foods),
        ],
      );
      await tester.tap(find.text('Match nutrition for all recipes'));
      await tester.pumpAndSettle();

      expect(
        find.text('Matched 1 ingredient. 1 still needs a match.'),
        findsOneWidget,
      );
      expect(foods.matches.values.single.foodId, garlic.id);
    });
  });
}
