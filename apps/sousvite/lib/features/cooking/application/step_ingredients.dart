import 'package:collection/collection.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/features/recipe/recipe.dart';

part 'step_ingredients.g.dart';

/// The ingredient lines a step uses, in recipe order, for its checklist
/// (DESIGN_SYSTEM.md §10.3).
///
/// For now a line belongs to a step when the step mentions the line's
/// name. Smart step text (MEA-2) replaces this body with its ingredient
/// matching; nothing else changes.
@riverpod
class StepIngredientIds() extends _$StepIngredientIds {
  @override
  List<IngredientLineId> build(RecipeId recipeId, RecipeStepId stepId) {
    final text = ref.watch(
      recipeStepProvider(
        recipeId,
        stepId,
      ).select((step) => step?.text.toLowerCase() ?? ''),
    );
    final lines = ref.watch(ingredientLinesProvider(recipeId)).value ?? [];
    return [
      for (final line in lines)
        if (line.name case final name? when name.trim().isNotEmpty)
          if (text.contains(name.trim().toLowerCase())) line.id,
    ];
  }

  @override
  bool updateShouldNotify(
    List<IngredientLineId> previous,
    List<IngredientLineId> next,
  ) => !const ListEquality<IngredientLineId>().equals(previous, next);
}
