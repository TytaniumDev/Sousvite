import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/nutrition/application/food_choice.dart';
import 'package:sousvite/features/nutrition/application/nutrition_actions.dart';

import '../fakes.dart';

typedef _F = NutritionFixtures;

void main() {
  group(NutritionActions, () {
    late FakeFoodRepository foods;
    late FakeUserRecipePrefsRepository prefs;
    late NutritionActions actions;
    final line = _F.line('l1');

    setUp(() {
      foods = FakeFoodRepository();
      prefs = FakeUserRecipePrefsRepository();
      actions = NutritionActions(
        foods: foods,
        prefs: prefs,
        newId: () => 'new',
      );
    });

    test('matches a saved food, confirmed by the user', () async {
      final oats = _F.food('oats');

      await actions.chooseFood(line, SavedFoodChoice(oats), gramWeight: 80);

      final match = foods.matches.values.single;
      expect(match.id, const NutritionMatchId('new'));
      expect(match.ingredientLineId, line.id);
      expect(match.foodId, oats.id);
      expect(match.gramWeight, 80);
      expect(match.userConfirmed, isTrue);
      expect(foods.foods, isEmpty);
    });

    test('caches an online food and replaces the current match', () async {
      final bar = _F.food('bar', source: NutritionSource.openFoodFacts);
      final current = _F.match('l1', 'oats', 80);
      await foods.saveMatch(current);

      await actions.chooseFood(
        line,
        OnlineFoodChoice((food: bar, nutrients: const [], portions: const [])),
        gramWeight: 40,
        current: current,
      );

      expect(foods.foods[bar.id], bar);
      final match = foods.matches.values.single;
      expect(match.id, current.id);
      expect(match.source, NutritionSource.openFoodFacts);
    });

    test('corrects the weight and removes a match', () async {
      final match = _F.match('l1', 'oats', 80);
      await foods.saveMatch(match);

      await actions.setGramWeight(match, 90);
      expect(foods.matches[match.id]!.gramWeight, 90);
      expect(foods.matches[match.id]!.userConfirmed, isTrue);

      await actions.removeMatch(match);
      expect(foods.matches, isEmpty);
    });

    test('remembers the serving count, keeping other settings', () async {
      await actions.setServings(_F.recipeId, Quantity(6));
      expect(prefs.prefs[_F.recipeId]!.servings, Quantity(6));

      await prefs.savePrefs(
        prefs.prefs[_F.recipeId]!.copyWith(unitSystem: UnitSystem.metric),
      );
      await actions.setServings(
        _F.recipeId,
        Quantity(2),
        current: prefs.prefs[_F.recipeId],
      );

      expect(
        prefs.prefs[_F.recipeId],
        UserRecipePrefs(
          recipeId: _F.recipeId,
          servings: Quantity(2),
          unitSystem: UnitSystem.metric,
        ),
      );
    });

    test('is provided with the repositories', () {
      final container = ProviderContainer.test(
        overrides: [
          foodRepositoryProvider.overrideWithValue(foods),
          userRecipePrefsRepositoryProvider.overrideWithValue(prefs),
        ],
      );

      expect(container.read(nutritionActionsProvider), isA<NutritionActions>());
    });
  });
}
