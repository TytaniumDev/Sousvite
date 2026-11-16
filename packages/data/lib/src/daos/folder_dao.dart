import 'package:data/src/app_database.dart';
import 'package:data/src/tables/folder_tables.dart';
import 'package:data/src/tables/recipe_tables.dart';
import 'package:drift/drift.dart';

part 'folder_dao.g.dart';

/// Queries for folders and their recipes.
///
/// Writes here record no changes: `DriftFolderRepository` wraps them in a
/// `ChangeRecorder` write, and the sync appliers call them directly.
@DriftAccessor(tables: [Folders, FolderEntries, Recipes])
class FolderDao(super.attachedDatabase)
    extends DatabaseAccessor<AppDatabase>
    with _$FolderDaoMixin {
  /// Every folder by name, ignoring case.
  Selectable<FolderRow> allFolders() => select(folders)
    ..orderBy([
      (row) => OrderingTerm.asc(row.name.lower()),
      (row) => OrderingTerm.asc(row.id),
    ]);

  /// The folder with [id].
  Selectable<FolderRow> folder(String id) =>
      select(folders)..where((row) => row.id.equals(id));

  /// Entries of [folderId], oldest first. Entries whose recipe is gone are
  /// left out.
  Selectable<FolderEntryRow> entriesOf(String folderId) {
    final query =
        select(folderEntries).join([
            innerJoin(recipes, recipes.id.equalsExp(folderEntries.recipeId)),
          ])
          ..where(folderEntries.folderId.equals(folderId))
          ..orderBy([
            OrderingTerm.asc(folderEntries.addedAt),
            OrderingTerm.asc(folderEntries.recipeId),
          ]);
    return query.map((row) => row.readTable(folderEntries));
  }

  /// Every entry of [folderId], including those whose recipe is gone.
  Future<List<FolderEntryRow>> allEntriesOf(String folderId) => (select(
    folderEntries,
  )..where((row) => row.folderId.equals(folderId))).get();

  /// The entry putting [recipeId] in [folderId].
  Selectable<FolderEntryRow> entry(String folderId, String recipeId) =>
      select(folderEntries)..where(
        (row) => row.folderId.equals(folderId) & row.recipeId.equals(recipeId),
      );

  /// Inserts or replaces a folder row.
  Future<void> upsertFolder(FoldersCompanion row) =>
      into(folders).insertOnConflictUpdate(row);

  /// Inserts or replaces an entry row.
  Future<void> upsertEntry(FolderEntriesCompanion row) =>
      into(folderEntries).insertOnConflictUpdate(row);

  /// Deletes the folder row with [id], leaving its entries.
  Future<void> deleteFolder(String id) =>
      (delete(folders)..where((row) => row.id.equals(id))).go();

  /// Deletes the entry putting [recipeId] in [folderId].
  Future<void> deleteEntry(String folderId, String recipeId) =>
      (delete(folderEntries)..where(
            (row) =>
                row.folderId.equals(folderId) & row.recipeId.equals(recipeId),
          ))
          .go();
}
