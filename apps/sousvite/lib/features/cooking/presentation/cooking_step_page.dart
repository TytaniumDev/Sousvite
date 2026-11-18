import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:measuring/measuring.dart';
import 'package:sousvite/features/cooking/application/checked_ingredients.dart';
import 'package:sousvite/features/cooking/application/cooking_timers.dart';
import 'package:sousvite/features/cooking/application/step_ingredients.dart';
import 'package:sousvite/features/recipe/recipe.dart';
import 'package:sousvite/features/settings/settings.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/units/unit_words.dart';

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
      StepMeasuringGuides(recipeId: recipeId, stepId: stepId),
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

/// Which of your cups and spoons measure each amount in the step:
/// "¾ cup flour: ½ cup + ¼ cup" (DESIGN_SYSTEM.md §10.3).
class const StepMeasuringGuides({
  /// The recipe being cooked.
  required final RecipeId recipeId,

  /// The step whose amounts these are.
  required final RecipeStepId stepId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mentions = ref
        .watch(stepPartsProvider(recipeId, stepId))
        .mentions
        .toList();
    final owned = ref.watch(ownedMeasuringToolsProvider).value;
    if (mentions.isEmpty || owned == null) return const SizedBox.shrink();
    final factor = ref.watch(recipeScaleProvider(recipeId));
    final system = ref.watch(recipeUnitSystemProvider(recipeId));
    final tools = [for (final tool in owned) Amount(tool.capacity, tool.unit)];
    return Column(
      crossAxisAlignment: .start,
      spacing: AppSpacing.space3,
      children: [
        for (final mention in mentions)
          if (_plan(
                shownAmount(mention.amount, factor: factor, system: system),
                tools,
              )
              case final plan?)
            _MeasuringGuideRow(
              amount: shownAmount(
                mention.amount,
                factor: factor,
                system: system,
              ),
              name: mention.name,
              plan: plan,
            ),
      ],
    );
  }

  /// The tools for [amount], or null when it can't be measured with cups
  /// and spoons or is exactly one tool already.
  static List<ToolUse>? _plan(Amount amount, List<Amount> tools) {
    final plan = decompose(amount, tools: tools);
    if (plan == null) return null;
    if (plan case [ToolUse(count: 1, :final tool)] when tool == amount) {
      return null;
    }
    return plan;
  }
}

class const _MeasuringGuideRow({
  required final Amount amount,
  required final String name,
  required final List<ToolUse> plan,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = context.appText.cookingIngredient;
    final unit = l10n.unitWord(amount.unit, amount.quantity);
    return Column(
      crossAxisAlignment: .start,
      spacing: AppSpacing.space1,
      children: [
        Text(
          '${AmountText.textFor(amount.quantity, unit)} $name',
          style: style,
        ),
        MeasuringGuide(
          style: style,
          tools: [
            for (final use in plan)
              for (var i = 0; i < use.count; i++)
                (
                  quantity: use.tool.quantity,
                  unit: l10n.unitWord(use.tool.unit, use.tool.quantity) ?? '',
                ),
          ],
        ),
      ],
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
