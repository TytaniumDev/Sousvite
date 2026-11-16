import 'package:collection/collection.dart';
import 'package:data/src/app_database.dart';
import 'package:data/src/change_log/change_recorder.dart';
import 'package:data/src/change_log/entity_applier.dart';
import 'package:data/src/change_log/materializing_applier.dart';
import 'package:data/src/daos/folder_dao.dart';
import 'package:data/src/folders/folder_codecs.dart';
import 'package:data/src/folders/folder_rows.dart';
import 'package:domain/domain.dart';

/// [FolderRepository] over the local database.
///
/// Writes go through [recorder] like every repository (see
/// `DriftRecipeRepository`); watch streams skip repeated values.
final class DriftFolderRepository(
  /// The database the folders and the change log live in.
  final AppDatabase database, {

  /// Records each write's changes for sync.
  required final ChangeRecorder recorder,

  /// Reads the wall clock, for when a recipe is added. Tests pass a fake.
  final DateTime Function() now = DateTime.now,
}) implements FolderRepository {
  FolderDao get _dao => database.folderDao;

  static final _folders = FolderCodec();
  static final _entries = FolderEntryCodec();

  /// Writes remote changes for folders and entries, by entity kind, for
  /// `DriftLocalStore`.
  Map<String, EntityApplier> get appliers => {
    _folders.entity: MaterializingApplier(
      database,
      codec: _folders,
      write: (folder) => _dao.upsertFolder(folder.toCompanion()),
      remove: _dao.deleteFolder,
    ),
    _entries.entity: MaterializingApplier(
      database,
      codec: _entries,
      write: (entry) => _dao.upsertEntry(entry.toCompanion()),
      remove: (id) {
        final [folderId, recipeId] = id.split('/');
        return _dao.deleteEntry(folderId, recipeId);
      },
    ),
  };

  @override
  Stream<List<Folder>> watchFolders() => _dao
      .allFolders()
      .watch()
      .map((rows) => [for (final row in rows) row.toEntity()])
      .distinct(const ListEquality<Folder>().equals);

  @override
  Stream<List<RecipeId>> watchRecipeIdsInFolder(FolderId folderId) => _dao
      .entriesOf(folderId.value)
      .watch()
      .map((rows) => [for (final row in rows) RecipeId(row.recipeId)])
      .distinct(const ListEquality<RecipeId>().equals);

  @override
  Future<Folder?> getFolder(FolderId id) async =>
      (await _dao.folder(id.value).getSingleOrNull())?.toEntity();

  @override
  Future<void> saveFolder(Folder folder) => recorder.write((changes) async {
    final before = await _dao.folder(folder.id.value).getSingleOrNull();
    changes.setChanged(_folders, folder, before: before?.toEntity());
    await _dao.upsertFolder(folder.toCompanion());
  });

  /// Deletes the folder and its entries. The recipes stay in the library.
  @override
  Future<void> deleteFolder(FolderId id) => recorder.write((changes) async {
    for (final entry in await _dao.allEntriesOf(id.value)) {
      await _dao.deleteEntry(entry.folderId, entry.recipeId);
      changes.delete(_entries.entity, _entries.idOf(entry.toEntity()));
    }
    await _dao.deleteFolder(id.value);
    changes.delete(_folders.entity, id.value);
  });

  @override
  Future<void> addRecipeToFolder(FolderId folderId, RecipeId recipeId) =>
      recorder.write((changes) async {
        final existing = await _dao
            .entry(folderId.value, recipeId.value)
            .getSingleOrNull();
        if (existing != null) return;
        final entry = FolderEntry(
          folderId: folderId,
          recipeId: recipeId,
          addedAt: now(),
        );
        changes.setChanged(_entries, entry);
        await _dao.upsertEntry(entry.toCompanion());
      });

  @override
  Future<void> removeRecipeFromFolder(FolderId folderId, RecipeId recipeId) =>
      recorder.write((changes) async {
        final existing = await _dao
            .entry(folderId.value, recipeId.value)
            .getSingleOrNull();
        if (existing == null) return;
        await _dao.deleteEntry(folderId.value, recipeId.value);
        changes.delete(
          _entries.entity,
          FolderEntryCodec.entryId(folderId, recipeId),
        );
      });
}
