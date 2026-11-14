import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'excluded_ingredients.g.dart';

/// The ingredient lines left out when adding [recipeId] to the grocery
/// list. Every line is included until the user unchecks it (PRD 7.7).
@riverpod
class ExcludedIngredients() extends _$ExcludedIngredients {
  @override
  Set<IngredientLineId> build(RecipeId recipeId) => const {};

  /// Includes [lineId] if it was left out, and leaves it out otherwise.
  void toggle(IngredientLineId lineId) => state = state.contains(lineId)
      ? ({...state}..remove(lineId))
      : {...state, lineId};
}
