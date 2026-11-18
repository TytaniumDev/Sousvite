import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/application/recipe_importers.dart';
import 'package:sousvite/features/import/application/recipe_url.dart';

part 'url_import.g.dart';

/// Imports a recipe from a web address. The state is the imported
/// recipe's id once saved, null before anything is imported, or an
/// [ImportFailure].
@riverpod
class UrlImport() extends _$UrlImport {
  @override
  FutureOr<RecipeId?> build() => null;

  /// Imports the recipe at [text] and saves it in [folderId], so the user
  /// can review it in the editor (PRD 7.2).
  Future<void> import(String text, {FolderId? folderId}) async {
    final url = parseRecipeUrl(text);
    if (url == null) {
      state = AsyncError(const ImportFailure(.invalidUrl), StackTrace.current);
      return;
    }
    final importer = ref.read(urlImporterProvider);
    final recipes = ref.read(recipeRepositoryProvider);
    final folders = folderId == null
        ? null
        : ref.read(folderRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final snapshot = await importer.importUrl(url);
      await recipes.saveSnapshot(snapshot);
      await folders?.addRecipeToFolder(folderId!, snapshot.recipe.id);
      return snapshot.recipe.id;
    });
  }

  /// Back to the empty form, such as after opening the imported recipe.
  void reset() => state = const AsyncData(null);
}
