import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/grocery/application/combine_grocery_items.dart';
import 'package:sousvite/features/grocery/application/excluded_ingredients.dart';
import 'package:sousvite/features/grocery/application/grocery_entry.dart';
import 'package:sousvite/features/grocery/application/grocery_line_name.dart';
import 'package:sousvite/features/nutrition/nutrition.dart';

part 'grocery_providers.g.dart';

/// The grocery list the app shows, or null before anything was added.
///
/// The app keeps one list (the nav destination is "Grocery list"), so this
/// is the oldest list. Recipes are added to it until it is cleared.
@riverpod
Stream<GroceryListId?> currentGroceryListId(Ref ref) => ref
    .watch(groceryRepositoryProvider)
    .watchLists()
    .map(_oldestListId)
    .distinct();

GroceryListId? _oldestListId(List<GroceryList> lists) {
  if (lists.isEmpty) return null;
  return lists.reduce((a, b) => b.createdAt.isBefore(a.createdAt) ? b : a).id;
}

/// The items on the current list, in list order.
@riverpod
Stream<List<GroceryItem>> groceryItems(Ref ref) async* {
  final listId = await ref.watch(currentGroceryListIdProvider.future);
  if (listId == null) {
    yield const [];
    return;
  }
  yield* ref.watch(groceryRepositoryProvider).watchItems(listId);
}

/// The current list combined and grouped for display.
///
/// Widgets `select` the part they show, such as one entry, so a change to
/// one item rebuilds only its row (ENGINEERING.md §5).
@riverpod
AsyncValue<GroceryView> groceryView(Ref ref) {
  final matches = ref.watch(groceryMatchesProvider);
  return ref
      .watch(groceryItemsProvider)
      .whenData((items) => combineGroceryItems(items, matches: matches));
}

/// The nutrition match of every recipe line on the list, by line id, so
/// items can combine by the food they matched and be weighed. Empty for a
/// recipe whose matches are still loading.
@riverpod
Map<IngredientLineId, NutritionMatch> groceryMatches(Ref ref) {
  final items = ref.watch(groceryItemsProvider).value ?? const [];
  return {
    for (final recipeId in {for (final item in items) ?item.sourceRecipeId})
      ...?ref.watch(nutritionMatchesProvider(recipeId)).value,
  };
}

/// A recipe's title, for showing where a grocery entry came from. Null while
/// loading and once the recipe is deleted.
@riverpod
Stream<String?> groceryRecipeTitle(Ref ref, RecipeId recipeId) => ref
    .watch(recipeRepositoryProvider)
    .watchRecipe(recipeId)
    .map((recipe) => recipe?.title)
    .distinct();

/// A recipe's ingredient lines, for the add-to-list sheet.
@riverpod
Stream<List<IngredientLine>> groceryRecipeLines(Ref ref, RecipeId recipeId) =>
    ref.watch(recipeRepositoryProvider).watchIngredientLines(recipeId);

/// How many of [recipeId]'s included lines would combine with an entry
/// already on the list, for the add-to-list sheet's summary.
@riverpod
int groceryCombiningLineCount(Ref ref, RecipeId recipeId) {
  final lines = ref.watch(groceryRecipeLinesProvider(recipeId)).value;
  if (lines == null) return 0;
  final excluded = ref.watch(excludedIngredientsProvider(recipeId));
  final view = ref.watch(groceryViewProvider).value;
  if (view == null) return 0;
  final matches = ref.watch(nutritionMatchesProvider(recipeId)).value;
  return lines
      .where(
        (line) =>
            !excluded.contains(line.id) &&
            view.entryFor(
                  groceryNameOf(line),
                  foodId: matches?[line.id]?.foodId,
                ) !=
                null,
      )
      .length;
}
