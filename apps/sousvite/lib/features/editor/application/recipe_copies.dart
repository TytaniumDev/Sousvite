import 'package:clock/clock.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:uuid/uuid.dart';

part 'recipe_copies.g.dart';

/// Duplicates, deletes, and restores whole recipes from the editor.
@riverpod
RecipeCopies recipeCopies(Ref ref) =>
    RecipeCopies(ref.watch(recipeRepositoryProvider));

/// See [recipeCopiesProvider].
class const RecipeCopies(final RecipeRepository _repository) {
  /// Saves a copy of [source] named [title], with new ids throughout.
  /// Returns the copy's id.
  Future<RecipeId> duplicate(RecipeSnapshot source, {required String title}) {
    final now = clock.now();
    final recipeId = RecipeId(const Uuid().v4());
    final copy = source.copyAs(recipeId, newId: const Uuid().v4);
    return _repository
        .saveSnapshot(
          copy.copyWith(
            recipe: copy.recipe.copyWith(
              title: title,
              createdAt: now,
              updatedAt: now,
            ),
          ),
        )
        .then((_) => recipeId);
  }

  /// Deletes the recipe with its lines, sections, and steps.
  Future<void> delete(RecipeId recipeId) => _repository.deleteRecipe(recipeId);

  /// Puts back a deleted recipe, for Undo.
  Future<void> restore(RecipeSnapshot snapshot) =>
      _repository.saveSnapshot(snapshot);
}
