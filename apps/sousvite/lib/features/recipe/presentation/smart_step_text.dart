import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:measuring/measuring.dart';
import 'package:sousvite/features/recipe/application/jarred_garlic.dart';
import 'package:sousvite/features/recipe/application/recipe_scale.dart';
import 'package:sousvite/features/recipe/application/recipe_units.dart';
import 'package:sousvite/features/recipe/application/step_parts.dart';
import 'package:sousvite/features/settings/settings.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/units/unit_words.dart';

/// A step's words with each ingredient's amount placed inline (smart step
/// text, ENGINEERING.md §13), scaled and converted like the ingredient
/// list. The recipe page and cooking mode both show steps with this.
///
/// Rebuilds when the step's parts change, and when the servings or units
/// change only if the step has an amount to show. Garlic cloves follow the
/// jarred garlic setting, which only steps that mention them watch.
class const SmartStepText({
  /// The recipe the step belongs to.
  required final RecipeId recipeId,

  /// The step to show.
  required final RecipeStepId stepId,

  /// The style of the words. Defaults to `bodyLarge`, as [StepText] does.
  final TextStyle? style,

  /// The style of the amounts. Defaults to `context.appText.amount`, as
  /// [StepText] does.
  final TextStyle? amountStyle,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parts = ref.watch(stepPartsProvider(recipeId, stepId));
    return StepText(
      segments: parts.mentions.isEmpty
          ? [
              for (final words in parts.whereType<StepWords>())
                StepTextSegment(words.text),
            ]
          : _segments(context, ref, parts),
      style: style,
      amountStyle: amountStyle,
    );
  }

  /// [parts] as segments, with each mention's amount scaled and converted.
  /// Only called for a step with mentions, so a step without any doesn't
  /// watch the servings or units.
  List<StepSegment> _segments(
    BuildContext context,
    WidgetRef ref,
    List<StepPart> parts,
  ) {
    final factor = ref.watch(recipeScaleProvider(recipeId));
    final system = ref.watch(recipeUnitSystemProvider(recipeId));
    final jarred =
        parts.mentions.any(_isGarlicCloves) &&
        ref.watch(jarredGarlicControllerProvider);
    final l10n = context.l10n;

    Amount show(StepMention mention, Amount written) => shownAmount(
      written,
      factor: factor,
      system: system,
      asJarredGarlic: jarred && _isGarlicCloves(mention),
    );

    StepAmountSegment inline(Amount shown, {String? countWord}) =>
        StepAmountSegment(
          quantity: shown.quantity,
          unit: l10n.unitWord(shown.unit, shown.quantity, countWord: countWord),
        );

    // "2–3 cups": the unit once, after the top, unless the two ends are
    // shown in different units.
    List<StepSegment> range(Amount from, Amount to, {String? countWord}) => [
      if (from.unit == to.unit)
        StepAmountSegment(quantity: from.quantity)
      else
        inline(from),
      const StepTextSegment('–'),
      inline(to, countWord: countWord),
    ];

    return [
      for (final part in parts)
        ...switch (part) {
          StepWords(:final text) => [StepTextSegment(text)],
          StepMention(
            :final amount,
            :final amountMax,
            :final countWord,
            :final name,
          ) =>
            [
              if (amountMax == null)
                inline(show(part, amount), countWord: countWord)
              else
                ...range(
                  show(part, amount),
                  show(part, Amount(amountMax, amount.unit)),
                  countWord: countWord,
                ),
              StepTextSegment(' $name'),
            ],
        },
    ];
  }
}

bool _isGarlicCloves(StepMention mention) => isGarlicCloves(
  name: mention.name,
  unit: mention.amount.unit,
  countWord: mention.countWord,
);
