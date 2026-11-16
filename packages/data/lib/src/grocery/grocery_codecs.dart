import 'package:data/src/change_log/entity_codec.dart';
import 'package:data/src/change_log/field_values.dart';
import 'package:domain/domain.dart';

/// [GroceryList] fields in the change log.
final class GroceryListCodec() implements EntityCodec<GroceryList> {
  @override
  String get entity => 'grocery_list';

  @override
  String idOf(GroceryList value) => value.id.value;

  @override
  Map<String, Object?> encode(GroceryList value) => {
    'name': value.name,
    'createdAt': encodeDateTime(value.createdAt),
  };

  @override
  GroceryList? decode(String id, Map<String, Object?> fields) {
    final name = fields['name'];
    final createdAt = decodeDateTime(fields['createdAt']);
    if (name is! String || createdAt == null) return null;
    return GroceryList(id: GroceryListId(id), name: name, createdAt: createdAt);
  }
}

/// [GroceryItem] fields in the change log.
final class GroceryItemCodec() implements EntityCodec<GroceryItem> {
  @override
  String get entity => 'grocery_item';

  @override
  String idOf(GroceryItem value) => value.id.value;

  @override
  Map<String, Object?> encode(GroceryItem value) => {
    'listId': value.listId.value,
    'name': value.name,
    'sortKey': value.sortKey.value,
    'quantity': encodeQuantity(value.quantity),
    'unit': encodeEnum(value.unit),
    'countWord': value.countWord,
    'storeSection': value.storeSection,
    'checked': value.checked,
    'sourceIngredientLineId': value.sourceIngredientLineId?.value,
    'sourceRecipeId': value.sourceRecipeId?.value,
  };

  @override
  GroceryItem? decode(String id, Map<String, Object?> fields) {
    if (fields case {
      'listId': final String listId,
      'name': final String name,
      'sortKey': final String sortKey,
    }) {
      final lineId = fields['sourceIngredientLineId'] as String?;
      final recipeId = fields['sourceRecipeId'] as String?;
      return GroceryItem(
        id: GroceryItemId(id),
        listId: GroceryListId(listId),
        name: name,
        sortKey: SortKey(sortKey),
        quantity: decodeQuantity(fields['quantity']),
        unit: decodeEnum(Unit.values, fields['unit']),
        countWord: fields['countWord'] as String?,
        storeSection: fields['storeSection'] as String?,
        checked: fields['checked'] as bool? ?? false,
        sourceIngredientLineId: lineId == null
            ? null
            : IngredientLineId(lineId),
        sourceRecipeId: recipeId == null ? null : RecipeId(recipeId),
      );
    }
    return null;
  }
}
