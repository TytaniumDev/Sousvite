import 'package:collection/collection.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/library/application/library_filter.dart';
import 'package:sousvite/features/library/application/library_scope.dart';
import 'package:sousvite/features/recipe/recipe.dart';
import 'package:sousvite/shared/async/combine_async.dart';

part 'library_recipes.g.dart';

/// Every recipe id, newest first.
@riverpod
Stream<List<RecipeId>> allRecipeIds(Ref ref) =>
    ref.watch(recipeRepositoryProvider).watchRecipeIds();

/// The ids of the recipes in one folder, in the repository's order.
@riverpod
Stream<List<RecipeId>> folderRecipeIds(Ref ref, FolderId folderId) =>
    ref.watch(folderRepositoryProvider).watchRecipeIdsInFolder(folderId);

/// The ids of recipes in at least one folder.
@riverpod
Stream<Set<RecipeId>> filedRecipeIds(Ref ref) =>
    ref.watch(folderRepositoryProvider).watchRecipeIdsInAnyFolder();

/// The recipes in [scope], newest first, before any search.
@riverpod
AsyncValue<List<RecipeId>> scopeRecipeIds(Ref ref, LibraryScope scope) {
  final all = ref.watch(allRecipeIdsProvider);
  return switch (scope) {
    AllRecipes() => all,
    FolderRecipes(:final folderId) => combineAsync2(
      all,
      ref.watch(folderRecipeIdsProvider(folderId)),
      (ids, inFolder) => _keepOnly(ids, inFolder.toSet()),
    ),
    UnsortedRecipes() => combineAsync2(
      all,
      ref.watch(filedRecipeIdsProvider),
      (ids, filed) => [
        for (final id in ids)
          if (!filed.contains(id)) id,
      ],
    ),
  };
}

/// The ids of recipes matching [query] by title, ingredient, or folder.
@riverpod
Stream<List<RecipeId>> recipeSearch(Ref ref, String query) =>
    ref.watch(recipeRepositoryProvider).watchSearch(query);

/// The recipes the page showing [scope] lists, newest first, kept to those
/// matching its search.
@riverpod
AsyncValue<List<RecipeId>> visibleRecipeIds(Ref ref, LibraryScope scope) {
  final inScope = ref.watch(scopeRecipeIdsProvider(scope));
  final query = ref.watch(libraryQueryProvider(scope)).trim();
  if (query.isEmpty) return inScope;
  return combineAsync2(
    inScope,
    ref.watch(recipeSearchProvider(query)),
    (ids, matches) => _keepOnly(ids, matches.toSet()),
  );
}

/// How many recipes [scope] holds. Null while loading.
@riverpod
int? scopeRecipeCount(Ref ref, LibraryScope scope) =>
    ref.watch(scopeRecipeIdsProvider(scope).select((ids) => ids.value?.length));

/// The photos on a tile: those of the newest recipes in [scope] that have
/// one, at most [maxCount].
///
/// Notifies only when that list changes, so renaming a recipe or adding
/// one without a photo doesn't rebuild the tile.
@riverpod
class CoverPhotos() extends _$CoverPhotos {
  /// The most photos a tile shows.
  static const int maxCount = 4;

  @override
  List<String> build(LibraryScope scope) {
    final recipeIds =
        ref.watch(scopeRecipeIdsProvider(scope)).value ?? const [];
    final photoRefs = <String>[];
    for (final recipeId in recipeIds) {
      if (photoRefs.length == maxCount) break;
      final photoRef = ref.watch(
        recipeProvider(recipeId).select((recipe) => recipe.value?.photoRef),
      );
      if (photoRef != null) photoRefs.add(photoRef);
    }
    return photoRefs;
  }

  @override
  bool updateShouldNotify(List<String> previous, List<String> next) =>
      !const ListEquality<String>().equals(previous, next);
}

/// [ids] in their own order, keeping only those in [allowed].
List<RecipeId> _keepOnly(List<RecipeId> ids, Set<RecipeId> allowed) => [
  for (final id in ids)
    if (allowed.contains(id)) id,
];
