// An interface has no code to run; only its empty primary constructor
// would show up, as an uncovered line.
// coverage:ignore-file

import 'package:domain/src/entities/folder.dart';
import 'package:domain/src/value_objects/ids.dart';

/// Folders and which recipes are in them.
abstract interface class FolderRepository() {
  Stream<List<Folder>> watchFolders();

  Stream<List<RecipeId>> watchRecipeIdsInFolder(FolderId folderId);

  /// The ids of recipes in at least one folder, in no particular order.
  /// The library lists recipes left out of it as unsorted.
  Stream<Set<RecipeId>> watchRecipeIdsInAnyFolder();

  /// The folders [recipeId] is in, in no particular order.
  Stream<Set<FolderId>> watchFolderIdsOf(RecipeId recipeId);

  Future<Folder?> getFolder(FolderId id);

  Future<void> saveFolder(Folder folder);

  Future<void> deleteFolder(FolderId id);

  Future<void> addRecipeToFolder(FolderId folderId, RecipeId recipeId);

  Future<void> removeRecipeFromFolder(FolderId folderId, RecipeId recipeId);
}
