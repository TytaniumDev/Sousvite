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

/// The folders one recipe is in.
@riverpod
Stream<Set<FolderId>> recipeFolderIds(Ref ref, RecipeId recipeId) =>
    ref.watch(folderRepositoryProvider).watchFolderIdsOf(recipeId);

/// Whether [folderId] is the only folder [recipeId] is in, so taking the
/// recipe out would leave it in none. False while loading.
@riverpod
bool isOnlyFolder(Ref ref, FolderId folderId, RecipeId recipeId) => ref.watch(
  recipeFolderIdsProvider(recipeId).select(
    (ids) => ids.value?.length == 1 && (ids.value?.contains(folderId) ?? false),
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

  /// The recipes in [folderId] that are in no other folder: deleting the
  /// folder deletes them too, since every recipe belongs in a folder.
  Future<List<RecipeId>> recipesOnlyIn(FolderId folderId) =>
      _recipesOnlyIn(_repository, folderId);

  static Future<List<RecipeId>> _recipesOnlyIn(
    FolderRepository repository,
    FolderId folderId,
  ) async {
    final onlyHere = <RecipeId>[];
    for (final recipeId
        in await repository.watchRecipeIdsInFolder(folderId).first) {
      final folderIds = await repository.watchFolderIdsOf(recipeId).first;
      if (folderIds.length == 1 && folderIds.contains(folderId)) {
        onlyHere.add(recipeId);
      }
    }
    return onlyHere;
  }

  /// Deletes a folder, and the recipes in no other folder with it.
  /// Returns what [restore] needs to undo it, or null when the folder is
  /// gone already.
  Future<DeletedFolder?> delete(FolderId folderId) async {
    final repository = _repository;
    final recipes = ref.read(recipeRepositoryProvider);
    final folder = await repository.getFolder(folderId);
    if (folder == null) return null;
    final recipeIds = await repository.watchRecipeIdsInFolder(folderId).first;
    final snapshots = <RecipeSnapshot>[];
    for (final recipeId in await _recipesOnlyIn(repository, folderId)) {
      final snapshot = await recipes.getSnapshot(recipeId);
      if (snapshot != null) snapshots.add(snapshot);
    }
    await repository.deleteFolder(folderId);
    for (final snapshot in snapshots) {
      await recipes.deleteRecipe(snapshot.recipe.id);
    }
    return (folder: folder, recipeIds: recipeIds, recipes: snapshots);
  }

  /// Puts back a folder that [delete] removed, with its recipes.
  Future<void> restore(DeletedFolder deleted) async {
    final repository = _repository;
    final recipes = ref.read(recipeRepositoryProvider);
    for (final snapshot in deleted.recipes) {
      await recipes.saveSnapshot(snapshot);
    }
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

/// A deleted folder, the recipes it held, and the whole recipes deleted
/// with it, for undo.
typedef DeletedFolder = ({
  Folder folder,
  List<RecipeId> recipeIds,
  List<RecipeSnapshot> recipes,
});
