import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:measuring/measuring.dart';
import 'package:sousvite/features/cooking/application/checked_ingredients.dart';
import 'package:sousvite/features/cooking/application/cooking_timers.dart';
import 'package:sousvite/features/cooking/application/step_ingredients.dart';
import 'package:sousvite/features/recipe/recipe.dart';
import 'package:sousvite/l10n/l10n.dart';

/// One step: its text, its timers, and the ingredients it uses. On medium
/// and expanded windows in landscape the ingredients sit in a side pane
/// (DESIGN_SYSTEM.md §10.3).
class const CookingStepPage({
  /// The recipe being cooked.
  required final RecipeId recipeId,

  /// The step this page shows.
  required final RecipeStepId stepId,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final twoPanes =
        WindowSizeClass.of(context) != .compact &&
        MediaQuery.orientationOf(context) == .landscape;
    final step = [
      CookingStepText(recipeId: recipeId, stepId: stepId),
      const SizedBox(height: AppSpacing.space4),
      StepTimers(recipeId: recipeId, stepId: stepId),
    ];
    final ingredients = StepIngredients(recipeId: recipeId, stepId: stepId);
    const padding = EdgeInsets.all(AppSpacing.space6);
    if (!twoPanes) {
      return ListView(
        padding: padding,
        children: [
          ...step,
          const SizedBox(height: AppSpacing.space6),
          ingredients,
        ],
      );
    }
    return Row(
      crossAxisAlignment: .start,
      children: [
        Expanded(
          child: ListView(padding: padding, children: step),
        ),
        Expanded(
          child: ListView(padding: padding, children: [ingredients]),
        ),
      ],
    );
  }
}

/// The step's words in the large cooking style. Read out when the step
/// changes.
class const CookingStepText({
  /// The recipe being cooked.
  required final RecipeId recipeId,

  /// The step to show.
  required final RecipeStepId stepId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(
      recipeStepProvider(recipeId, stepId).select((step) => step?.text ?? ''),
    );
    final large = WindowSizeClass.of(context) != .compact;
    final styles = context.appText;
    return Semantics(
      liveRegion: true,
      child: StepText(
        segments: [StepTextSegment(text)],
        style: large ? styles.cookingStepLarge : styles.cookingStep,
        amountStyle: large ? styles.cookingAmountLarge : styles.cookingAmount,
      ),
    );
  }
}

/// A timer chip for each time the step mentions ("bake 20 minutes").
class const StepTimers({
  /// The recipe being cooked.
  required final RecipeId recipeId,

  /// The step whose times these are.
  required final RecipeStepId stepId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timers = findTimers(
      ref.watch(
        recipeStepProvider(recipeId, stepId).select((step) => step?.text ?? ''),
      ),
    );
    if (timers.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.space2,
      runSpacing: AppSpacing.space2,
      children: [
        for (final (index, timer) in timers.indexed)
          _StepTimerChip(
            key: ValueKey(timerKey(stepId, index)),
            recipeId: recipeId,
            timerKey: timerKey(stepId, index),
            timer: timer,
          ),
      ],
    );
  }
}

/// One timer. A range counts down its shorter end, so you check early.
class const _StepTimerChip({
  required final RecipeId recipeId,
  required final String timerKey,
  required final StepTimer timer,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timers = ref.read(cookingTimersProvider(recipeId).notifier);
    return TimerChip(
      label: timer.text,
      duration: timer.minimum,
      doneLabel: context.l10n.cooking_timerDone,
      startedAt: ref.watch(timerStartedAtProvider(recipeId, timerKey)),
      onStart: () =>
          timers.start(timerKey, label: timer.text, duration: timer.minimum),
      onStop: () => timers.stop(timerKey),
    );
  }
}

/// A checklist of just this step's ingredients. Hidden when the step uses
/// none.
class const StepIngredients({
  /// The recipe being cooked.
  required final RecipeId recipeId,

  /// The step whose ingredients these are.
  required final RecipeStepId stepId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineIds = ref.watch(stepIngredientIdsProvider(recipeId, stepId));
    if (lineIds.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            context.l10n.cooking_stepIngredients,
            style: context.appText.cookingSection,
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        for (final lineId in lineIds)
          _CheckableIngredient(
            key: ValueKey(lineId),
            recipeId: recipeId,
            lineId: lineId,
          ),
      ],
    );
  }
}

class const _CheckableIngredient({
  required final RecipeId recipeId,
  required final IngredientLineId lineId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => RecipeIngredientRow(
    recipeId: recipeId,
    lineId: lineId,
    checked: ref.watch(isIngredientCheckedProvider(recipeId, lineId)),
    onChanged: (checked) => ref
        .read(checkedIngredientsProvider(recipeId).notifier)
        .setChecked(lineId, checked: checked),
  );
}
