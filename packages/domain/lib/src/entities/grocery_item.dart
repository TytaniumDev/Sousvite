import 'package:domain/src/value_objects/ids.dart';
import 'package:domain/src/value_objects/sort_key.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:units/units.dart';

part 'grocery_item.freezed.dart';

/// One item on a grocery list, either added by hand or from a recipe's
/// ingredient line (PRD 7.7).
@freezed
abstract class GroceryItem with _$GroceryItem {
  const factory({
    required GroceryItemId id,
    required GroceryListId listId,
    required String name,
    required SortKey sortKey,
    Quantity? quantity,
    Unit? unit,

    /// A count word used as the unit when [unit] has none, singular and
    /// lowercase, copied from the ingredient line: "clove" in "3 cloves
    /// garlic". Null when [unit] is set or the item has neither.
    String? countWord,

    /// Store section name used for grouping, such as "Produce".
    String? storeSection,
    @Default(false) bool checked,

    /// The ingredient line this came from, for combining. Null when manual.
    IngredientLineId? sourceIngredientLineId,
    RecipeId? sourceRecipeId,

    /// Whether the item combines with items whose lines matched the same
    /// food ("sugar" and "granulated sugar"). False once the user
    /// separates it; it then combines only with items of the same name.
    @Default(true) bool combinesByFood,
  }) = _GroceryItem;
}
