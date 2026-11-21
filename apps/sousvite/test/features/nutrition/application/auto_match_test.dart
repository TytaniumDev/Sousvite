import 'dart:async';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrition/nutrition.dart';
import 'package:sousvite/app/providers/bundled_foods.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/nutrition/application/auto_match.dart';
import 'package:sqlite3/sqlite3.dart';

import '../fakes.dart';

typedef _F = NutritionFixtures;

Food _usda(String id, String name) => Food(
  id: FoodId(id),
  source: NutritionSource.usda,
  externalId: id,
  name: name,
);

void main() {
  final garlic = _usda('usda:garlic', 'Garlic, raw');
  final milk = _usda('usda:milk', 'Milk, whole');
  final taro = _usda('usda:taro', 'Taro leaves, raw');

  group(AutoMatch, () {
    late FakeFoodRepository foods;
    late FakeRecipeRepository recipes;
    late AutoMatch autoMatch;
    var nextId = 0;

    IngredientLine line(String id, String? name, {Quantity? quantity}) =>
        _F.line(id, quantity: quantity, unit: Unit.gram).copyWith(name: name);

    setUp(() async {
      foods = FakeFoodRepository()
        ..addFood(garlic)
        ..addFood(milk)
        ..addFood(taro);
      recipes = FakeRecipeRepository();
      autoMatch = AutoMatch(
        foods: foods,
        recipes: recipes,
        matcher: FoodMatcher([garlic, milk, taro]),
        newId: () => 'm${nextId++}',
      );
      await recipes.saveRecipe(_F.recipe());
    });

    test('matches lines whose food clearly fits, weighing them', () async {
      await recipes.saveIngredientLine(
        line('garlic', 'garlic', quantity: Quantity(10)),
      );

      expect(await autoMatch.matchRecipe(_F.recipeId), (
        matched: 1,
        unmatched: 0,
      ));
      final match = foods.matches.values.single;
      expect(match.ingredientLineId, const IngredientLineId('garlic'));
      expect(match.foodId, garlic.id);
      expect(match.source, NutritionSource.usda);
      expect(match.gramWeight, 10);
      expect(match.userConfirmed, isFalse);
    });

    test('leaves unclear, unnamed, and unweighable lines alone', () async {
      await recipes.saveIngredientLine(
        line('mint', 'mint leaves', quantity: Quantity(5)),
      );
      await recipes.saveIngredientLine(line('blank', null));
      await recipes.saveIngredientLine(line('salt', 'garlic'));
      await recipes.saveIngredientLine(line('none', 'saffron'));

      expect(await autoMatch.matchRecipe(_F.recipeId), (
        matched: 0,
        unmatched: 4,
      ));
      expect(foods.matches, isEmpty);
    });

    test('never changes a line that already has a match', () async {
      await recipes.saveIngredientLine(
        line('milk', 'garlic', quantity: Quantity(10)),
      );
      final existing = _F.match('milk', milk.id.value, 244);
      await foods.saveMatch(existing);

      expect(await autoMatch.matchRecipe(_F.recipeId), (
        matched: 0,
        unmatched: 0,
      ));
      expect(foods.matches.values.single, existing);
    });

    test('matches every recipe in the library', () async {
      await recipes.saveIngredientLine(
        line('garlic', 'garlic', quantity: Quantity(10)),
      );
      await recipes.saveRecipe(
        _F.recipe().copyWith(id: const RecipeId('soup')),
      );
      await recipes.saveIngredientLine(
        line('mint', 'mint leaves').copyWith(recipeId: const RecipeId('soup')),
      );

      expect(await autoMatch.matchLibrary(), (matched: 1, unmatched: 1));
    });
  });

  test('the app matches against every generic food once they load', () async {
    final foods = FakeFoodRepository()..addFood(garlic);
    final bundled = Completer<BundledFoods>();
    final container = ProviderContainer.test(
      overrides: [
        bundledFoodsProvider.overrideWith((ref) => bundled.future),
        // Rebuilds once the bundled foods load, as the app's does.
        foodRepositoryProvider.overrideWith((ref) {
          ref.watch(bundledFoodsProvider);
          return foods;
        }),
        recipeRepositoryProvider.overrideWithValue(FakeRecipeRepository()),
      ],
    );

    final loading = container.read(autoMatchProvider.future);
    await pumpEventQueue();
    // Matching before the bundled foods load would find nothing.
    expect(container.read(autoMatchProvider).isLoading, isTrue);

    final emptyFile = BundledFoods(sqlite3.openInMemory());
    addTearDown(emptyFile.close);
    bundled.complete(emptyFile);
    final autoMatch = await loading;

    expect(
      autoMatch.matcher.match('garlic'),
      isA<FoodMatched>().having((m) => m.food, 'food', garlic),
    );
  });
}
