import 'package:collection/collection.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/features/recipe/recipe.dart';

part 'step_ingredients.g.dart';

/// The ingredient lines a step uses, in the order it mentions them, for
/// its checklist (DESIGN_SYSTEM.md §10.3). A line belongs to the step
/// where smart step text places its amount.
@riverpod
class StepIngredientIds() extends _$StepIngredientIds {
  @override
  List<IngredientLineId> build(RecipeId recipeId, RecipeStepId stepId) => [
    ...{
      for (final mention
          in ref.watch(stepPartsProvider(recipeId, stepId)).mentions)
        mention.lineId,
    },
  ];

  @override
  bool updateShouldNotify(
    List<IngredientLineId> previous,
    List<IngredientLineId> next,
  ) => !const ListEquality<IngredientLineId>().equals(previous, next);
}
