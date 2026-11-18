import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/application/recipe_importers.dart';
import 'package:sousvite/features/import/application/recipe_url.dart';
import 'package:sousvite/features/nutrition/nutrition.dart';

part 'url_import.g.dart';

/// Imports a recipe from a web address. The state is the imported
/// recipe's id once saved, null before anything is imported, or an
/// [ImportFailure].
@riverpod
class UrlImport() extends _$UrlImport {
  @override
  FutureOr<RecipeId?> build() => null;

  /// Imports the recipe at [text] and saves it, so the user can review it
  /// in the editor (PRD 7.2). Ingredients that clearly fit a USDA food are
  /// matched for nutrition right away.
  Future<void> import(String text) async {
    final url = parseRecipeUrl(text);
    if (url == null) {
      state = AsyncError(const ImportFailure(.invalidUrl), StackTrace.current);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final snapshot = await ref.read(urlImporterProvider).importUrl(url);
      await ref.read(recipeRepositoryProvider).saveSnapshot(snapshot);
      final autoMatch = await ref.read(autoMatchProvider.future);
      await autoMatch.matchRecipe(snapshot.recipe.id);
      return snapshot.recipe.id;
    });
  }

  /// Back to the empty form, such as after opening the imported recipe.
  void reset() => state = const AsyncData(null);
}
