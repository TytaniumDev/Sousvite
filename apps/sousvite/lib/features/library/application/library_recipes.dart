import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/library/application/library_filter.dart';
import 'package:sousvite/shared/async/combine_async.dart';

part 'library_recipes.g.dart';

/// Every recipe id, newest first.
@riverpod
Stream<List<RecipeId>> allRecipeIds(Ref ref) =>
    ref.watch(recipeRepositoryProvider).watchRecipeIds();

/// The ids of the recipes in one folder.
@riverpod
Stream<List<RecipeId>> folderRecipeIds(Ref ref, FolderId folderId) =>
    ref.watch(folderRepositoryProvider).watchRecipeIdsInFolder(folderId);

/// The ids of recipes matching [query] by title, ingredient, or folder.
@riverpod
Stream<List<RecipeId>> recipeSearch(Ref ref, String query) =>
    ref.watch(recipeRepositoryProvider).watchSearch(query);

/// The recipes the library shows: those in the chosen folder that match
/// the search, newest first.
@riverpod
AsyncValue<List<RecipeId>> visibleRecipeIds(Ref ref) {
  final all = ref.watch(allRecipeIdsProvider);
  final folder = ref.watch(libraryFolderProvider);
  final query = ref.watch(libraryQueryProvider).trim();

  final inFolder = folder == null
      ? all
      : combineAsync2(
          all,
          ref.watch(folderRecipeIdsProvider(folder)),
          _keepOnly,
        );
  if (query.isEmpty) return inFolder;
  return combineAsync2(
    inFolder,
    ref.watch(recipeSearchProvider(query)),
    _keepOnly,
  );
}

/// [ids] in their own order, keeping only those also in [allowed].
List<RecipeId> _keepOnly(List<RecipeId> ids, List<RecipeId> allowed) {
  final keep = allowed.toSet();
  return [
    for (final id in ids)
      if (keep.contains(id)) id,
  ];
}
