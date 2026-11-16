import 'package:collection/collection.dart';
import 'package:data/src/app_database.dart';
import 'package:data/src/change_log/change_recorder.dart';
import 'package:data/src/change_log/entity_applier.dart';
import 'package:data/src/change_log/materializing_applier.dart';
import 'package:data/src/daos/grocery_dao.dart';
import 'package:data/src/grocery/grocery_codecs.dart';
import 'package:data/src/grocery/grocery_rows.dart';
import 'package:domain/domain.dart';

/// [GroceryRepository] over the local database.
///
/// Writes go through [recorder] like every repository (see
/// `DriftRecipeRepository`); watch streams skip repeated values. Checking
/// an item off records only `checked`, so two people shopping from one
/// list never undo each other's edits.
final class DriftGroceryRepository(
  /// The database the lists and the change log live in.
  final AppDatabase database, {

  /// Records each write's changes for sync.
  required final ChangeRecorder recorder,
}) implements GroceryRepository {
  GroceryDao get _dao => database.groceryDao;

  static final _lists = GroceryListCodec();
  static final _items = GroceryItemCodec();

  /// Writes remote changes for lists and items, by entity kind, for
  /// `DriftLocalStore`.
  Map<String, EntityApplier> get appliers => {
    _lists.entity: MaterializingApplier(
      database,
      codec: _lists,
      write: (list) => _dao.upsertList(list.toCompanion()),
      remove: _dao.deleteList,
    ),
    _items.entity: MaterializingApplier(
      database,
      codec: _items,
      write: (item) => _dao.upsertItem(item.toCompanion()),
      remove: _dao.deleteItem,
    ),
  };

  @override
  Stream<List<GroceryList>> watchLists() => _dao
      .allLists()
      .watch()
      .map((rows) => [for (final row in rows) row.toEntity()])
      .distinct(const ListEquality<GroceryList>().equals);

  @override
  Stream<List<GroceryItem>> watchItems(GroceryListId listId) => _dao
      .itemsOf(listId.value)
      .watch()
      .map((rows) => [for (final row in rows) row.toEntity()])
      .distinct(const ListEquality<GroceryItem>().equals);

  @override
  Future<void> saveList(GroceryList list) => recorder.write((changes) async {
    final before = await _dao.list(list.id.value).getSingleOrNull();
    changes.setChanged(_lists, list, before: before?.toEntity());
    await _dao.upsertList(list.toCompanion());
  });

  /// Deletes the list with its items.
  @override
  Future<void> deleteList(GroceryListId id) => recorder.write((changes) async {
    for (final item in await _dao.itemsOf(id.value).get()) {
      await _dao.deleteItem(item.id);
      changes.delete(_items.entity, item.id);
    }
    await _dao.deleteList(id.value);
    changes.delete(_lists.entity, id.value);
  });

  @override
  Future<void> saveItem(GroceryItem item) => recorder.write((changes) async {
    final before = await _dao.item(item.id.value).getSingleOrNull();
    changes.setChanged(_items, item, before: before?.toEntity());
    await _dao.upsertItem(item.toCompanion());
  });

  @override
  Future<void> deleteItem(GroceryItemId id) => recorder.write((changes) async {
    await _dao.deleteItem(id.value);
    changes.delete(_items.entity, id.value);
  });
}
