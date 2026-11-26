import 'package:domain/domain.dart';
import 'package:sousvite/features/grocery/application/grocery_amounts.dart';
import 'package:sousvite/features/grocery/application/grocery_entry.dart';

/// How much of a grocery entry one recipe needs. A null `recipeId` holds
/// the items added by hand.
typedef GrocerySource = ({RecipeId? recipeId, List<GroceryAmount> amounts});

/// [entry]'s items grouped by the recipe they came from, in the order the
/// recipes first appear, each with its amounts added up.
List<GrocerySource> grocerySources(GroceryEntry entry) {
  final itemsByRecipe = <RecipeId?, List<GroceryItem>>{};
  for (final item in entry.items) {
    (itemsByRecipe[item.sourceRecipeId] ??= []).add(item);
  }
  return [
    for (final MapEntry(key: recipeId, value: items) in itemsByRecipe.entries)
      (recipeId: recipeId, amounts: groceryAmounts(items)),
  ];
}
