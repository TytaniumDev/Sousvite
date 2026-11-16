import 'package:data/src/app_database.dart';
import 'package:domain/domain.dart';

/// Reads a [Folder] from its row.
extension FolderRowMapping on FolderRow {
  /// The entity this row stores.
  Folder toEntity() =>
      Folder(id: FolderId(id), name: name, createdAt: createdAt);
}

/// Writes a [Folder] as a row.
extension FolderCompanionMapping on Folder {
  /// A row with every column set, the time in UTC.
  FoldersCompanion toCompanion() => FoldersCompanion.insert(
    id: id.value,
    name: name,
    createdAt: createdAt.toUtc(),
  );
}

/// Reads a [FolderEntry] from its row.
extension FolderEntryRowMapping on FolderEntryRow {
  /// The entity this row stores.
  FolderEntry toEntity() => FolderEntry(
    folderId: FolderId(folderId),
    recipeId: RecipeId(recipeId),
    addedAt: addedAt,
  );
}

/// Writes a [FolderEntry] as a row.
extension FolderEntryCompanionMapping on FolderEntry {
  /// A row with every column set, the time in UTC.
  FolderEntriesCompanion toCompanion() => FolderEntriesCompanion.insert(
    folderId: folderId.value,
    recipeId: recipeId.value,
    addedAt: addedAt.toUtc(),
  );
}
