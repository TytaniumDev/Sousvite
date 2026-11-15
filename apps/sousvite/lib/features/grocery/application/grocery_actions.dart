import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/grocery/application/grocery_ids.dart';

part 'grocery_actions.g.dart';

/// Changes to the grocery list. Screens call these from callbacks with
/// `ref.read(groceryActionsProvider)`.
class GroceryActions({
  required final GroceryRepository repository,
  required final GroceryIds ids,
  required final DateTime Function() now,
}) {
  /// Adds [lines] from [recipeId] to the list, creating the list if there
  /// is none yet (PRD 7.7).
  Future<void> addFromRecipe(
    RecipeId recipeId,
    List<IngredientLine> lines,
  ) async {
    if (lines.isEmpty) return;
    final listId = await _listId();
    for (final line in lines) {
      await repository.saveItem(
        GroceryItem(
          id: ids.itemId(),
          listId: listId,
          name: line.name ?? line.rawText,
          sortKey: ids.sortKey(),
          storeSection: StoreSection.of(line.name ?? line.rawText).name,
          quantity: line.quantity,
          unit: line.unit,
          sourceIngredientLineId: line.id,
          sourceRecipeId: recipeId,
        ),
      );
    }
  }

  /// Adds an item typed by hand. Blank names are ignored.
  Future<void> addManualItem(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await repository.saveItem(
      GroceryItem(
        id: ids.itemId(),
        listId: await _listId(),
        name: trimmed,
        sortKey: ids.sortKey(),
        storeSection: StoreSection.of(trimmed).name,
      ),
    );
  }

  /// Checks or unchecks every item in [items], such as one combined entry.
  Future<void> setChecked(List<GroceryItem> items, {required bool checked}) =>
      _saveAll([
        for (final item in items)
          if (item.checked != checked) item.copyWith(checked: checked),
      ]);

  /// Removes [items]. Pass them to [restore] to undo.
  Future<void> remove(List<GroceryItem> items) async {
    for (final item in items) {
      await repository.deleteItem(item.id);
    }
  }

  /// Puts back items that [remove] took off the list.
  Future<void> restore(List<GroceryItem> items) => _saveAll(items);

  Future<void> _saveAll(List<GroceryItem> items) async {
    for (final item in items) {
      await repository.saveItem(item);
    }
  }

  Future<GroceryListId> _listId() async {
    final lists = await repository.watchLists().first;
    if (lists.isNotEmpty) {
      return lists
          .reduce((a, b) => b.createdAt.isBefore(a.createdAt) ? b : a)
          .id;
    }
    final list = GroceryList(
      id: ids.listId(),
      // The app has one list and titles it itself; the name is kept for
      // when lists can be named.
      name: '',
      createdAt: now(),
    );
    await repository.saveList(list);
    return list.id;
  }
}

@riverpod
GroceryActions groceryActions(Ref ref) => GroceryActions(
  repository: ref.watch(groceryRepositoryProvider),
  ids: ref.watch(groceryIdsProvider),
  now: DateTime.now,
);
