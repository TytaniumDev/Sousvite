import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/library/application/library_recipes.dart';
import 'package:uuid/uuid.dart';

part 'folders.g.dart';

/// Every folder, in the repository's order.
@riverpod
Stream<List<Folder>> folders(Ref ref) =>
    ref.watch(folderRepositoryProvider).watchFolders();

/// The folder ids, in order. Null while loading.
///
/// Notifies only when folders are added, removed, or reordered, not when
/// one is renamed, so the folder grid doesn't rebuild for a new name.
@riverpod
class FolderIds() extends _$FolderIds {
  @override
  List<FolderId>? build() => ref.watch(
    foldersProvider.select(
      (folders) => folders.value?.map((folder) => folder.id).toList(),
    ),
  );

  @override
  bool updateShouldNotify(List<FolderId>? previous, List<FolderId>? next) =>
      !const ListEquality<FolderId>().equals(previous, next);
}

/// One folder's name. Notifies only when that name changes.
@riverpod
String? folderName(Ref ref, FolderId folderId) => ref.watch(
  foldersProvider.select(
    (folders) => folders.value
        ?.where((folder) => folder.id == folderId)
        .firstOrNull
        ?.name,
  ),
);

/// Whether one recipe is in one folder. Null while loading.
@riverpod
bool? isRecipeInFolder(Ref ref, FolderId folderId, RecipeId recipeId) =>
    ref.watch(
      folderRecipeIdsProvider(folderId)
          .select((ids) => ids.value?.contains(recipeId)),
    );

/// Creates, renames, and deletes folders, and moves recipes in and out
/// of them. A recipe can be in several folders (PRD 7.1).
@riverpod
class FolderEditor() extends _$FolderEditor {
  @override
  void build() {}

  // Each method reads the repository once, before its first await: nothing
  // watches this provider, so it may be disposed while a write is running.
  FolderRepository get _repository => ref.read(folderRepositoryProvider);

  /// Creates a folder named [name] and returns its id.
  Future<FolderId> create(String name) async {
    final folder = Folder(
      id: FolderId(const Uuid().v4()),
      name: name.trim(),
      createdAt: clock.now(),
    );
    await _repository.saveFolder(folder);
    return folder.id;
  }

  Future<void> rename(FolderId folderId, String name) async {
    final repository = _repository;
    final folder = await repository.getFolder(folderId);
    if (folder == null) return;
    await repository.saveFolder(folder.copyWith(name: name.trim()));
  }

  /// Deletes a folder, leaving its recipes in the library. Returns what
  /// [restore] needs to undo it, or null when the folder is gone already.
  Future<DeletedFolder?> delete(FolderId folderId) async {
    final repository = _repository;
    final folder = await repository.getFolder(folderId);
    if (folder == null) return null;
    final recipeIds = await repository.watchRecipeIdsInFolder(folderId).first;
    await repository.deleteFolder(folderId);
    return (folder: folder, recipeIds: recipeIds);
  }

  /// Puts back a folder that [delete] removed, with its recipes.
  Future<void> restore(DeletedFolder deleted) async {
    final repository = _repository;
    await repository.saveFolder(deleted.folder);
    for (final recipeId in deleted.recipeIds) {
      await repository.addRecipeToFolder(deleted.folder.id, recipeId);
    }
  }

  /// Puts [recipeId] in [folderId] or takes it out.
  Future<void> setRecipeInFolder(
    FolderId folderId,
    RecipeId recipeId, {
    required bool inFolder,
  }) => inFolder
      ? _repository.addRecipeToFolder(folderId, recipeId)
      : _repository.removeRecipeFromFolder(folderId, recipeId);
}

/// A deleted folder and the recipes it held, for undo.
typedef DeletedFolder = ({Folder folder, List<RecipeId> recipeIds});
