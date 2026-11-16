import 'package:domain/src/entities/recipe_snapshot.dart';
import 'package:domain/src/repositories/recipe_repository.dart';
import 'package:domain/src/value_objects/ids.dart';

/// Reads whole recipes from a [RecipeRepository].
extension RecipeSnapshots on RecipeRepository {
  /// The recipe [recipeId] with all its parts as they are now, or null when
  /// there is no such recipe.
  Future<RecipeSnapshot?> getSnapshot(RecipeId recipeId) async {
    final recipe = await getRecipe(recipeId);
    if (recipe == null) return null;
    return RecipeSnapshot(
      recipe: recipe,
      ingredientSections: await watchIngredientSections(recipeId).first,
      ingredientLines: await watchIngredientLines(recipeId).first,
      stepSections: await watchStepSections(recipeId).first,
      steps: await watchSteps(recipeId).first,
    );
  }
}
