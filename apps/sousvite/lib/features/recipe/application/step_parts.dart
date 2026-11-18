import 'package:collection/collection.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:measuring/measuring.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/features/recipe/application/recipe_data.dart';
import 'package:sousvite/features/recipe/application/recipe_outline.dart';
import 'package:sousvite/shared/async/combine_async.dart';

part 'step_parts.g.dart';

/// Every step's words with its ingredient mentions found (smart step text,
/// ENGINEERING.md §13), by step. Each ingredient's amount goes at its
/// first mention in cooking order: loose steps, then each section.
///
/// Amounts are as written; screens show them with `shownAmount`, so steps
/// scale and convert exactly like the ingredient list. The recipe page and
/// cooking mode both read these.
@riverpod
AsyncValue<Map<RecipeStepId, List<StepPart>>> smartStepParts(
  Ref ref,
  RecipeId recipeId,
) => combineAsync2(
  combineAsync2(
    ref.watch(stepOutlineProvider(recipeId)).whenData((o) => o.steps),
    ref.watch(recipeStepsProvider(recipeId)),
    (order, steps) => (order: order, steps: steps),
  ),
  ref.watch(ingredientLinesProvider(recipeId)),
  (recipe, lines) {
    final texts = {for (final step in recipe.steps) step.id: step.text};
    final ids = [for (final step in recipe.order) step.stepId];
    final parts = smartSteps([for (final id in ids) texts[id] ?? ''], lines);
    return {for (final (i, id) in ids.indexed) id: parts[i]};
  },
);

/// One step's parts. Notifies only when this step's parts change.
@riverpod
class StepParts() extends _$StepParts {
  @override
  List<StepPart> build(RecipeId recipeId, RecipeStepId stepId) =>
      ref.watch(
        smartStepPartsProvider(recipeId)
            .select((parts) => parts.value?[stepId]),
      ) ??
      const [];

  @override
  bool updateShouldNotify(List<StepPart> previous, List<StepPart> next) =>
      !const ListEquality<StepPart>().equals(previous, next);
}

/// The ingredient mentions in one step, in order.
extension StepMentions on List<StepPart> {
  /// The mentions with amounts placed inline.
  Iterable<StepMention> get mentions => whereType<StepMention>();
}
