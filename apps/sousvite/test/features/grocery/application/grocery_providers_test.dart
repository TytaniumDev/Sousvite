import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/grocery/application/excluded_ingredients.dart';
import 'package:sousvite/features/grocery/application/grocery_providers.dart';
import 'package:sousvite/features/nutrition/nutrition.dart';

import '../../nutrition/fakes.dart' show FakeFoodRepository;
import '../fakes.dart';

typedef _F = GroceryFixtures;

void main() {
  late FakeGroceryRepository groceries;
  late FakeRecipeRepository recipes;
  late FakeFoodRepository foods;
  late ProviderContainer container;

  setUp(() {
    groceries = FakeGroceryRepository();
    recipes = FakeRecipeRepository();
    foods = FakeFoodRepository();
    container = ProviderContainer.test(
      overrides: [
        groceryRepositoryProvider.overrideWithValue(groceries),
        recipeRepositoryProvider.overrideWithValue(recipes),
        foodRepositoryProvider.overrideWithValue(foods),
      ],
    );
  });

  Future<GroceryList> saveList(String id, DateTime createdAt) async {
    final list = GroceryList(
      id: GroceryListId(id),
      name: '',
      createdAt: createdAt,
    );
    await groceries.saveList(list);
    return list;
  }

  group('currentGroceryListId', () {
    test('is null with no lists, then the oldest list', () async {
      final subscription = container.listen(
        currentGroceryListIdProvider,
        (_, _) {},
      );
      expect(await container.read(currentGroceryListIdProvider.future), null);

      await saveList('newer', DateTime.utc(2026));
      await saveList('older', DateTime.utc(2025));
      await pumpEventQueue();

      expect(subscription.read().value, const GroceryListId('older'));
    });
  });

  group('groceryItems', () {
    test('is empty with no list', () async {
      container.listen(groceryItemsProvider, (_, _) {});
      expect(await container.read(groceryItemsProvider.future), isEmpty);
    });

    test('follows the current list', () async {
      await saveList('list', DateTime.utc(2026));
      await groceries.saveItem(_F.item('b'));
      await groceries.saveItem(_F.item('a'));
      await groceries.saveItem(
        _F.item('other', listId: const GroceryListId('x')),
      );

      container.listen(groceryItemsProvider, (_, _) {});
      final items = await container.read(groceryItemsProvider.future);

      expect(items.map((item) => item.name), ['a', 'b']);
    });
  });

  group('groceryView', () {
    test('combines the current items and updates with them', () async {
      await saveList('list', DateTime.utc(2026));
      await groceries.saveItem(_F.item('a', name: 'onion'));
      final subscription = container.listen(groceryViewProvider, (_, _) {});
      await container.read(groceryItemsProvider.future);

      expect(subscription.read().value!.entries.keys, ['onion']);

      await groceries.saveItem(_F.item('b', name: 'Onion'));
      await pumpEventQueue();

      expect(subscription.read().value!.entries['onion']!.items, hasLength(2));
    });
  });

  group('groceryRecipeTitle', () {
    test('follows the recipe title and is null once deleted', () async {
      const id = RecipeId('soup');
      await recipes.saveRecipe(_F.recipe('soup', title: 'Soup'));
      const gone = RecipeId('gone');
      container
        ..listen(groceryRecipeTitleProvider(id), (_, _) {})
        ..listen(groceryRecipeTitleProvider(gone), (_, _) {});

      expect(
        await container.read(groceryRecipeTitleProvider(id).future),
        'Soup',
      );
      expect(
        await container.read(groceryRecipeTitleProvider(gone).future),
        isNull,
      );
    });
  });

  group('groceryRecipeLines', () {
    test('lists the recipe lines in order', () async {
      await recipes.saveIngredientLine(_F.line('b', recipeId: 'soup'));
      await recipes.saveIngredientLine(_F.line('a', recipeId: 'soup'));
      await recipes.saveIngredientLine(_F.line('c', recipeId: 'stew'));

      final provider = groceryRecipeLinesProvider(const RecipeId('soup'));
      container.listen(provider, (_, _) {});
      final lines = await container.read(provider.future);

      expect(lines.map((line) => line.id.value), ['a', 'b']);
    });
  });

  group('groceryCombiningLineCount', () {
    test('counts included lines whose item is already on the list', () async {
      const soup = RecipeId('soup');
      await saveList('list', DateTime.utc(2026));
      await groceries.saveItem(_F.item('x', name: 'Onions'));
      await recipes.saveIngredientLine(
        _F.line('a', recipeId: 'soup', name: 'onion'),
      );
      await recipes.saveIngredientLine(
        _F.line('b', recipeId: 'soup', name: 'carrot'),
      );

      final provider = groceryCombiningLineCountProvider(soup);
      container.listen(provider, (_, _) {});
      await container.read(groceryRecipeLinesProvider(soup).future);
      await container.read(groceryItemsProvider.future);
      expect(container.read(provider), 1);

      container
          .read(excludedIngredientsProvider(soup).notifier)
          .toggle(const IngredientLineId('a'));
      expect(container.read(provider), 0);
    });

    test('counts a line matched to a food already on the list', () async {
      const soup = RecipeId('soup');
      const stew = RecipeId('stew');
      await saveList('list', DateTime.utc(2026));
      await groceries.saveItem(
        _F.item('x', name: 'white sugar', recipeId: stew),
      );
      await recipes.saveIngredientLine(
        _F.line('a', recipeId: 'soup', name: 'granulated sugar'),
      );
      for (final lineId in ['stew-x', 'a']) {
        await foods.saveMatch(
          NutritionMatch(
            id: NutritionMatchId(lineId),
            ingredientLineId: IngredientLineId(lineId),
            foodId: const FoodId('sugar'),
            source: NutritionSource.usda,
            gramWeight: 100,
          ),
        );
      }

      final provider = groceryCombiningLineCountProvider(soup);
      container.listen(provider, (_, _) {});
      await container.read(groceryRecipeLinesProvider(soup).future);
      await container.read(groceryItemsProvider.future);
      await container.read(nutritionMatchesProvider(soup).future);
      await container.read(nutritionMatchesProvider(stew).future);
      expect(container.read(provider), 1);
    });

    test('is zero while the lines load', () {
      expect(
        container.read(
          groceryCombiningLineCountProvider(const RecipeId('soup')),
        ),
        0,
      );
    });
  });
}
