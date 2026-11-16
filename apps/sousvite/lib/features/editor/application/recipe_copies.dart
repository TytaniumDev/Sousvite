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
    String newId() => const Uuid().v4();
    final now = clock.now();
    final recipeId = RecipeId(newId());
    final ingredientSections = {
      for (final section in source.ingredientSections)
        section.id: IngredientSectionId(newId()),
    };
    final stepSections = {
      for (final section in source.stepSections)
        section.id: StepSectionId(newId()),
    };
    final copy = RecipeSnapshot(
      recipe: source.recipe.copyWith(
        id: recipeId,
        title: title,
        createdAt: now,
        updatedAt: now,
      ),
      ingredientSections: [
        for (final section in source.ingredientSections)
          section.copyWith(
            id: ingredientSections[section.id]!,
            recipeId: recipeId,
          ),
      ],
      ingredientLines: [
        for (final line in source.ingredientLines)
          line.copyWith(
            id: IngredientLineId(newId()),
            recipeId: recipeId,
            sectionId: ingredientSections[line.sectionId],
          ),
      ],
      stepSections: [
        for (final section in source.stepSections)
          section.copyWith(id: stepSections[section.id]!, recipeId: recipeId),
      ],
      steps: [
        for (final step in source.steps)
          step.copyWith(
            id: RecipeStepId(newId()),
            recipeId: recipeId,
            sectionId: stepSections[step.sectionId],
          ),
      ],
    );
    return _repository.saveSnapshot(copy).then((_) => recipeId);
  }

  /// Deletes the recipe with its lines, sections, and steps.
  Future<void> delete(RecipeId recipeId) => _repository.deleteRecipe(recipeId);

  /// Puts back a deleted recipe, for Undo.
  Future<void> restore(RecipeSnapshot snapshot) =>
      _repository.saveSnapshot(snapshot);
}
