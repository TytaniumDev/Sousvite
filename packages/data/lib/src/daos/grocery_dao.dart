import 'package:data/src/app_database.dart';
import 'package:data/src/tables/grocery_tables.dart';
import 'package:drift/drift.dart';

part 'grocery_dao.g.dart';

/// Queries for grocery lists and items.
///
/// Writes here record no changes: `DriftGroceryRepository` wraps them in a
/// `ChangeRecorder` write, and the sync appliers call them directly.
@DriftAccessor(tables: [GroceryLists, GroceryItems])
class GroceryDao(super.attachedDatabase)
    extends DatabaseAccessor<AppDatabase>
    with _$GroceryDaoMixin {
  /// Every list, oldest first.
  Selectable<GroceryListRow> allLists() => select(groceryLists)
    ..orderBy([
      (row) => OrderingTerm.asc(row.createdAt),
      (row) => OrderingTerm.asc(row.id),
    ]);

  /// The list with [id].
  Selectable<GroceryListRow> list(String id) =>
      select(groceryLists)..where((row) => row.id.equals(id));

  /// The items of [listId] in sort order.
  Selectable<GroceryItemRow> itemsOf(String listId) => select(groceryItems)
    ..where((row) => row.listId.equals(listId))
    ..orderBy([
      (row) => OrderingTerm.asc(row.sortKey),
      (row) => OrderingTerm.asc(row.id),
    ]);

  /// The item with [id].
  Selectable<GroceryItemRow> item(String id) =>
      select(groceryItems)..where((row) => row.id.equals(id));

  /// Inserts or replaces a list row.
  Future<void> upsertList(GroceryListsCompanion row) =>
      into(groceryLists).insertOnConflictUpdate(row);

  /// Inserts or replaces an item row.
  Future<void> upsertItem(GroceryItemsCompanion row) =>
      into(groceryItems).insertOnConflictUpdate(row);

  /// Deletes the list row with [id], leaving its items.
  Future<void> deleteList(String id) =>
      (delete(groceryLists)..where((row) => row.id.equals(id))).go();

  /// Deletes the item row with [id].
  Future<void> deleteItem(String id) =>
      (delete(groceryItems)..where((row) => row.id.equals(id))).go();
}
