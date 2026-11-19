import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:measuring/measuring.dart';
import 'package:sousvite/features/cooking/application/checked_ingredients.dart';
import 'package:sousvite/features/cooking/application/cooking_timers.dart';
import 'package:sousvite/features/cooking/application/measuring_plan.dart';
import 'package:sousvite/features/cooking/application/step_ingredients.dart';
import 'package:sousvite/features/recipe/recipe.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/units/unit_words.dart';

/// One step: the ingredients it uses, its text, and its timers. The
/// ingredients come first so you can get them ready. With room for two
/// panes they sit in a side pane after the step instead (DESIGN_SYSTEM.md
/// §10.3).
class const CookingStepPage({
  /// The recipe being cooked.
  required final RecipeId recipeId,

  /// The step this page shows.
  required final RecipeStepId stepId,
  super.key,
}) extends StatelessWidget {
  static const _padding = EdgeInsets.all(AppSpacing.space6);

  @override
  Widget build(BuildContext context) {
    final step = [
      CookingStepText(recipeId: recipeId, stepId: stepId),
      const SizedBox(height: AppSpacing.space4),
      StepTimers(recipeId: recipeId, stepId: stepId),
    ];
    final ingredients = StepIngredients(recipeId: recipeId, stepId: stepId);
    return PaneLayout(
      main: (context, insets) => FadingEdges(
        child: ListView(padding: insets + _padding, children: step),
      ),
      side: (context, insets) => FadingEdges(
        child: ListView(padding: insets + _padding, children: [ingredients]),
      ),
      onePane: (context, insets) => FadingEdges(
        child: ListView(
          padding: insets + _padding,
          children: [ingredients, ...step],
        ),
      ),
    );
  }
}

/// The step's words in the large cooking style, with each ingredient's
/// amount placed inline, scaled and converted like the ingredient list.
/// Read out when the step changes.
class const CookingStepText({
  /// The recipe being cooked.
  required final RecipeId recipeId,

  /// The step to show.
  required final RecipeStepId stepId,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final large = WindowSizeClass.of(context) != .compact;
    final styles = context.appText;
    return Semantics(
      liveRegion: true,
      child: SmartStepText(
        recipeId: recipeId,
        stepId: stepId,
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

/// A compact checklist of just this step's ingredients, each with the
/// measuring tools for its amount. Hidden when the step uses none. Leaves
/// space under itself for the step text when it shows.
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space6),
      child: CompactDensity(
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                context.l10n.cooking_stepIngredients,
                style: context.appText.cookingSection,
              ),
            ),
            const SizedBox(height: AppSpacing.space1),
            for (final lineId in lineIds)
              _CheckableIngredient(
                key: ValueKey(lineId),
                recipeId: recipeId,
                lineId: lineId,
              ),
          ],
        ),
      ),
    );
  }
}

class const _CheckableIngredient({
  required final RecipeId recipeId,
  required final IngredientLineId lineId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(lineMeasuringPlanProvider(recipeId, lineId));
    return RecipeIngredientRow(
      recipeId: recipeId,
      lineId: lineId,
      checked: ref.watch(isIngredientCheckedProvider(recipeId, lineId)),
      onChanged: (checked) => ref
          .read(checkedIngredientsProvider(recipeId).notifier)
          .setChecked(lineId, checked: checked),
      guide: plan == null ? null : _MeasuringGuide(plan: plan),
    );
  }
}

/// "Use ½ Tbsp": the cups and spoons to fill, each as many times as it
/// takes.
class const _MeasuringGuide({required final List<ToolUse> plan})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MeasuringGuide(
      label: l10n.cooking_measureWith,
      tools: [
        for (final use in plan)
          for (var i = 0; i < use.count; i++)
            (
              quantity: use.tool.quantity,
              unit: l10n.unitWord(use.tool.unit, use.tool.quantity) ?? '',
            ),
      ],
    );
  }
}
