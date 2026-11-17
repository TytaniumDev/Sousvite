import 'package:data/src/app_database.dart';
import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

/// Reads a [GroceryList] from its row.
extension GroceryListRowMapping on GroceryListRow {
  /// The entity this row stores.
  GroceryList toEntity() =>
      GroceryList(id: GroceryListId(id), name: name, createdAt: createdAt);
}

/// Writes a [GroceryList] as a row.
extension GroceryListCompanionMapping on GroceryList {
  /// A row with every column set, the time in UTC.
  GroceryListsCompanion toCompanion() => GroceryListsCompanion.insert(
    id: id.value,
    name: name,
    createdAt: createdAt.toUtc(),
  );
}

/// Reads a [GroceryItem] from its row.
extension GroceryItemRowMapping on GroceryItemRow {
  /// The entity this row stores.
  GroceryItem toEntity() => GroceryItem(
    id: GroceryItemId(id),
    listId: GroceryListId(listId),
    name: name,
    sortKey: SortKey(sortKey),
    quantity: quantityNumerator == null || quantityDenominator == null
        ? null
        : Quantity(quantityNumerator!, quantityDenominator!),
    unit: unit,
    countWord: countWord,
    storeSection: storeSection,
    checked: checked,
    sourceIngredientLineId: sourceIngredientLineId == null
        ? null
        : IngredientLineId(sourceIngredientLineId!),
    sourceRecipeId: sourceRecipeId == null ? null : RecipeId(sourceRecipeId!),
  );
}

/// Writes a [GroceryItem] as a row.
extension GroceryItemCompanionMapping on GroceryItem {
  /// A row with every column set.
  GroceryItemsCompanion toCompanion() => GroceryItemsCompanion.insert(
    id: id.value,
    listId: listId.value,
    name: name,
    sortKey: sortKey.value,
    quantityNumerator: Value(quantity?.numerator),
    quantityDenominator: Value(quantity?.denominator),
    unit: Value(unit),
    countWord: Value(countWord),
    storeSection: Value(storeSection),
    checked: Value(checked),
    sourceIngredientLineId: Value(sourceIngredientLineId?.value),
    sourceRecipeId: Value(sourceRecipeId?.value),
  );
}
