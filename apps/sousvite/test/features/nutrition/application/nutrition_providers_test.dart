import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/app/services/nutrition_api.dart';
import 'package:sousvite/features/nutrition/application/food_choice.dart';
import 'package:sousvite/features/nutrition/application/nutrient.dart';
import 'package:sousvite/features/nutrition/application/nutrition_basis.dart';
import 'package:sousvite/features/nutrition/application/nutrition_providers.dart';

import '../fakes.dart';

typedef _F = NutritionFixtures;

void main() {
  late FakeFoodRepository foods;
  late FakeRecipeRepository recipes;
  late FakeUserRecipePrefsRepository prefs;
  late ProviderContainer container;
  const id = _F.recipeId;

  setUp(() async {
    foods = FakeFoodRepository();
    recipes = FakeRecipeRepository();
    prefs = FakeUserRecipePrefsRepository();
    container = ProviderContainer.test(
      overrides: [
        foodRepositoryProvider.overrideWithValue(foods),
        recipeRepositoryProvider.overrideWithValue(recipes),
        userRecipePrefsRepositoryProvider.overrideWithValue(prefs),
      ],
    );
    await recipes.saveRecipe(_F.recipe());
    await recipes.saveIngredientLine(_F.line('l1'));
    await recipes.saveIngredientLine(_F.line('l2'));
    foods
      ..addFood(_F.food('oats'), per100g: {'208': 400, '203': 10})
      ..addFood(_F.food('milk'), per100g: {'208': 60});
  });

  /// Listens to [provider] for the rest of the test and lets its streams
  /// and futures settle.
  Future<ProviderSubscription<T>> settle<T>(
    ProviderListenable<T> provider,
  ) async {
    final subscription = container.listen(provider, (_, _) {});
    await pumpEventQueue();
    return subscription;
  }

  group('batchNutrition', () {
    test('adds up matched lines and updates when a match changes', () async {
      await foods.saveMatch(_F.match('l1', 'oats', 100));
      final batch = await settle(batchNutritionProvider(id));

      expect(batch.read().value, {
        Nutrient.calories: 400,
        Nutrient.protein: 10,
      });

      await foods.saveMatch(_F.match('l2', 'milk', 200));
      await pumpEventQueue();

      expect(batch.read().value![Nutrient.calories], 520);
    });

    test('is loading until matches arrive, then reports errors', () async {
      final failing = ProviderContainer.test(
        overrides: [
          nutritionMatchesProvider(id)
              .overrideWith((ref) => Stream.error(StateError('broken'))),
        ],
      );
      final batch = failing.listen(batchNutritionProvider(id), (_, _) {});
      expect(batch.read().isLoading, isTrue);

      await pumpEventQueue();

      expect(batch.read().error, isA<StateError>());
    });

    test('reports a food whose nutrients fail to load', () async {
      final failing = ProviderContainer.test(
        overrides: [
          nutritionMatchesProvider(id).overrideWith(
            (ref) => Stream.value({
              const IngredientLineId('l1'): _F.match('l1', 'oats', 1),
            }),
          ),
          foodNutrientsProvider(const FoodId('oats'))
              .overrideWith((ref) => Future.error(StateError('broken'))),
        ],
      );
      final batch = failing.listen(batchNutritionProvider(id), (_, _) {});
      await pumpEventQueue();

      expect(batch.read().error, isA<StateError>());
    });
  });

  group('nutritionServings', () {
    test("uses the recipe's servings until the user picks", () async {
      final servings = await settle(nutritionServingsProvider(id));
      expect(servings.read().value, Quantity(4));

      await prefs.savePrefs(
        UserRecipePrefs(recipeId: id, servings: Quantity(6)),
      );
      await pumpEventQueue();

      expect(servings.read().value, Quantity(6));
    });

    test('is one serving for a missing recipe', () async {
      recipes.recipes.clear();
      final servings = await settle(
        nutritionServingsProvider(const RecipeId('gone')),
      );

      expect(servings.read().value, Quantity.one);
    });

    test('reports errors', () async {
      final failing = ProviderContainer.test(
        overrides: [
          nutritionPrefsProvider(id)
              .overrideWith((ref) => Stream.error(StateError('broken'))),
          recipeYieldProvider(id).overrideWith((ref) => const Stream.empty()),
        ],
      );
      final servings = failing.listen(nutritionServingsProvider(id), (_, _) {});
      expect(servings.read().isLoading, isTrue);
      await pumpEventQueue();

      expect(servings.read().error, isA<StateError>());
    });
  });

  group('displayedNutrition', () {
    test('divides by servings, or shows the batch', () async {
      await foods.saveMatch(_F.match('l1', 'oats', 100));
      final shown = await settle(displayedNutritionProvider(id));

      expect(shown.read().value![Nutrient.calories], 100);

      container
          .read(nutritionBasisControllerProvider(id).notifier)
          .select(.batch);
      await pumpEventQueue();

      expect(shown.read().value![Nutrient.calories], 400);
    });

    test('is loading, then reports errors', () {
      final failing = ProviderContainer.test(
        overrides: [
          batchNutritionProvider(id).overrideWithValue(const AsyncData({})),
          nutritionServingsProvider(id)
              .overrideWithValue(AsyncError(StateError('broken'), .empty)),
        ],
      );
      expect(
        failing.read(displayedNutritionProvider(id)).error,
        isA<StateError>(),
      );

      final loading = ProviderContainer.test(
        overrides: [
          batchNutritionProvider(id).overrideWithValue(const AsyncLoading()),
          nutritionServingsProvider(id)
              .overrideWithValue(const AsyncData(Quantity.one)),
        ],
      );
      expect(loading.read(displayedNutritionProvider(id)).isLoading, isTrue);
    });
  });

  group('unmatchedLineIds', () {
    test('lists lines without a match', () async {
      await foods.saveMatch(_F.match('l1', 'oats', 100));
      final unmatched = await settle(unmatchedLineIdsProvider(id));

      expect(unmatched.read().value, [const IngredientLineId('l2')]);
    });

    test('is loading, then reports errors', () async {
      final failing = ProviderContainer.test(
        overrides: [
          nutritionLinesProvider(id)
              .overrideWith((ref) => Stream.error(StateError('broken'))),
          nutritionMatchesProvider(id)
              .overrideWith((ref) => const Stream.empty()),
        ],
      );
      final unmatched = failing.listen(unmatchedLineIdsProvider(id), (_, _) {});
      expect(unmatched.read().isLoading, isTrue);

      await pumpEventQueue();

      expect(unmatched.read().error, isA<StateError>());
    });
  });

  group('lookups', () {
    test('read a food, its portions, and recipe yield', () async {
      expect(
        (await settle(nutritionFoodProvider(const FoodId('oats'))))
            .read()
            .value
            ?.name,
        'oats',
      );
      expect(
        (await settle(foodPortionsProvider(const FoodId('oats')))).read().value,
        isEmpty,
      );
      expect((await settle(recipeYieldProvider(id))).read().value, Quantity(4));
    });
  });

  group('foodSearch', () {
    test('is empty for a blank query', () async {
      final results = await settle(foodSearchProvider('  '));
      expect(results.read().value, isEmpty);
    });

    test('lists saved foods first, then new online ones', () async {
      final oats = _F.food('oats');
      final bar = _F.food('bar', source: NutritionSource.openFoodFacts);
      foods.searchResults = [oats];
      final online = ProviderContainer.test(
        overrides: [
          foodRepositoryProvider.overrideWithValue(foods),
          nutritionApiProvider.overrideWithValue(
            FakeNutritionApi([
              (food: oats, nutrients: const [], portions: const []),
              (food: bar, nutrients: const [], portions: const []),
            ]),
          ),
        ],
      );
      final results = online.listen(foodSearchProvider('oat'), (_, _) {});
      await pumpEventQueue();

      final choices = results.read().value!;
      expect(choices.map((choice) => choice.food), [oats, bar]);
      expect(choices.first, isA<SavedFoodChoice>());
      expect(choices.last, isA<OnlineFoodChoice>());
    });
  });
}
