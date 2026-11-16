import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/features/recipe/recipe.dart';

part 'cooking_steps.g.dart';

/// One step in cooking order, with the section it belongs to.
typedef CookingStep = ({StepSectionId? sectionId, RecipeStepId stepId});

/// Every step of [recipeId] in the order it is cooked: loose steps, then
/// each section in order (DESIGN_SYSTEM.md §10.3).
@riverpod
AsyncValue<List<CookingStep>> cookingSteps(Ref ref, RecipeId recipeId) =>
    ref.watch(stepOutlineProvider(recipeId)).whenData((o) => o.steps);

/// Which step is showing. Kept while the app runs, so leaving cooking mode
/// and coming back keeps your place (DESIGN_SYSTEM.md §10.3).
@Riverpod(keepAlive: true)
class CookingPosition() extends _$CookingPosition {
  @override
  int build(RecipeId recipeId) => 0;

  /// Shows the step at [index], from 0.
  void goTo(int index) => state = index < 0 ? 0 : index;

  /// Starts over from the first step, after finishing.
  void reset() => state = 0;
}

/// Where the cook is: the step's section and its place in the recipe.
typedef CookingProgress = ({
  StepSectionId? sectionId,
  int stepNumber,
  int stepCount,
});

/// The progress shown in the header, or null before the steps load or
/// when there are none. The position is clamped to the steps there are.
@riverpod
CookingProgress? cookingProgress(Ref ref, RecipeId recipeId) {
  final steps = ref.watch(cookingStepsProvider(recipeId)).value;
  if (steps == null || steps.isEmpty) return null;
  final index = ref
      .watch(cookingPositionProvider(recipeId))
      .clamp(0, steps.length - 1);
  return (
    sectionId: steps[index].sectionId,
    stepNumber: index + 1,
    stepCount: steps.length,
  );
}
