import 'package:domain/src/entities/recipe_snapshot.dart';
import 'package:domain/src/value_objects/ids.dart';

/// Copying a whole recipe, for duplicates and experiments (PRD 7.11).
extension RecipeSnapshotCopy on RecipeSnapshot {
  /// This snapshot as the recipe [recipeId], with a new id from [newId]
  /// for every section, line, and step. Lines and steps keep their
  /// sections, under the sections' new ids. The recipe's own fields are
  /// unchanged apart from its id.
  RecipeSnapshot copyAs(RecipeId recipeId, {required String Function() newId}) {
    final ingredientSectionIds = {
      for (final section in ingredientSections)
        section.id: IngredientSectionId(newId()),
    };
    final stepSectionIds = {
      for (final section in stepSections) section.id: StepSectionId(newId()),
    };
    return RecipeSnapshot(
      recipe: recipe.copyWith(id: recipeId),
      ingredientSections: [
        for (final section in ingredientSections)
          section.copyWith(
            id: ingredientSectionIds[section.id]!,
            recipeId: recipeId,
          ),
      ],
      ingredientLines: [
        for (final line in ingredientLines)
          line.copyWith(
            id: IngredientLineId(newId()),
            recipeId: recipeId,
            sectionId: ingredientSectionIds[line.sectionId],
          ),
      ],
      stepSections: [
        for (final section in stepSections)
          section.copyWith(id: stepSectionIds[section.id]!, recipeId: recipeId),
      ],
      steps: [
        for (final step in steps)
          step.copyWith(
            id: RecipeStepId(newId()),
            recipeId: recipeId,
            sectionId: stepSectionIds[step.sectionId],
          ),
      ],
    );
  }
}
