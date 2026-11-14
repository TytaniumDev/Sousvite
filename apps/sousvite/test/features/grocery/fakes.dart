import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';

/// Emits [read]'s value on listen and again after every [changes] event,
/// skipping repeats like a Drift watch query with `distinct()`.
Stream<T> _watch<T>(
  Stream<void> changes,
  T Function() read, {
  bool Function(T, T)? equals,
}) {
  late final StreamController<T> controller;
  StreamSubscription<void>? subscription;
  controller = StreamController<T>(
    onListen: () {
      controller.add(read());
      subscription = changes.listen((_) => controller.add(read()));
    },
    onCancel: () => subscription?.cancel(),
  );
  return controller.stream.distinct(equals);
}

/// An in-memory [GroceryRepository].
class FakeGroceryRepository() implements GroceryRepository {
  final lists = <GroceryListId, GroceryList>{};
  final items = <GroceryItemId, GroceryItem>{};
  final _changes = StreamController<void>.broadcast(sync: true);

  void _changed() => _changes.add(null);

  @override
  Stream<List<GroceryList>> watchLists() =>
      _watch(_changes.stream, () => lists.values.toList(), equals: listEquals);

  @override
  Stream<List<GroceryItem>> watchItems(GroceryListId listId) => _watch(
    _changes.stream,
    () =>
        items.values.where((item) => item.listId == listId).toList()
          ..sort((a, b) => a.sortKey.compareTo(b.sortKey.value)),
    equals: listEquals,
  );

  @override
  Future<void> saveList(GroceryList list) async {
    lists[list.id] = list;
    _changed();
  }

  @override
  Future<void> deleteList(GroceryListId id) async {
    lists.remove(id);
    items.removeWhere((_, item) => item.listId == id);
    _changed();
  }

  @override
  Future<void> saveItem(GroceryItem item) async {
    items[item.id] = item;
    _changed();
  }

  @override
  Future<void> deleteItem(GroceryItemId id) async {
    items.remove(id);
    _changed();
  }
}

/// A [RecipeRepository] holding recipes and ingredient lines in memory.
/// Methods grocery doesn't use throw.
class FakeRecipeRepository() extends Fake implements RecipeRepository {
  final recipes = <RecipeId, Recipe>{};
  final lines = <IngredientLineId, IngredientLine>{};
  final _changes = StreamController<void>.broadcast(sync: true);

  @override
  Stream<Recipe?> watchRecipe(RecipeId id) =>
      _watch(_changes.stream, () => recipes[id]);

  @override
  Stream<List<IngredientLine>> watchIngredientLines(RecipeId recipeId) =>
      _watch(
        _changes.stream,
        () =>
            lines.values.where((line) => line.recipeId == recipeId).toList()
              ..sort((a, b) => a.sortKey.compareTo(b.sortKey.value)),
        equals: listEquals,
      );

  @override
  Future<void> saveRecipe(Recipe recipe) async {
    recipes[recipe.id] = recipe;
    _changes.add(null);
  }

  @override
  Future<void> saveIngredientLine(IngredientLine line) async {
    lines[line.id] = line;
    _changes.add(null);
  }
}

/// Test data builders.
abstract final class GroceryFixtures() {
  static const listId = GroceryListId('list');

  static GroceryItem item(
    String id, {
    String? name,
    Quantity? quantity,
    Unit? unit,
    String? storeSection,
    bool checked = false,
    RecipeId? recipeId,
    GroceryListId listId = listId,
  }) => GroceryItem(
    id: GroceryItemId(id),
    listId: listId,
    name: name ?? id,
    sortKey: SortKey(id),
    quantity: quantity,
    unit: unit,
    storeSection: storeSection,
    checked: checked,
    sourceRecipeId: recipeId,
    sourceIngredientLineId: recipeId == null
        ? null
        : IngredientLineId('${recipeId.value}-$id'),
  );

  static Recipe recipe(String id, {String? title}) => Recipe(
    id: RecipeId(id),
    title: title ?? id,
    servings: Quantity(4),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  static IngredientLine line(
    String id, {
    required String recipeId,
    String? name,
    Quantity? quantity,
    Unit? unit,
  }) => IngredientLine(
    id: IngredientLineId(id),
    recipeId: RecipeId(recipeId),
    rawText: '${quantity ?? ''} ${unit?.name ?? ''} ${name ?? id}'.trim(),
    sortKey: SortKey(id),
    name: name,
    quantity: quantity,
    unit: unit,
  );
}
