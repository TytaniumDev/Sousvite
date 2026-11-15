import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:design_system/src/widgets/macro_bar.dart';
import 'package:design_system/src/widgets/macro_labels.dart';
import 'package:design_system/src/widgets/nutrition_format.dart';
import 'package:material_ui/material_ui.dart';

/// Calories with protein, carbs, and fat in grams, and the macro bar
/// (DESIGN_SYSTEM.md §9.2, §10.5).
///
/// Always labeled with its basis ("Per serving (1 of 4)", "Whole batch"),
/// so a number is never read without knowing what it covers.
class const MacroSummary({
  /// Calories (kcal).
  required final double calories,

  /// Protein in grams.
  required final double protein,

  /// Carbohydrates in grams.
  required final double carbs,

  /// Fat in grams.
  required final double fat,

  /// What the numbers cover, already worded: "Per serving (1 of 4)".
  required final String basisLabel,

  /// The words shown next to the numbers.
  required final MacroLabels labels,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          basisLabel,
          style: context.textStyles.labelLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.space1),
        _Calories(calories: calories, label: labels.calories),
        const SizedBox(height: AppSpacing.space3),
        Wrap(
          spacing: AppSpacing.space6,
          runSpacing: AppSpacing.space2,
          children: [
            _Macro(
              grams: protein,
              name: labels.protein,
              unit: labels.grams,
              color: colors.protein,
            ),
            _Macro(
              grams: carbs,
              name: labels.carbs,
              unit: labels.grams,
              color: colors.carbs,
            ),
            _Macro(
              grams: fat,
              name: labels.fat,
              unit: labels.grams,
              color: colors.fat,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        MacroBar(protein: protein, carbs: carbs, fat: fat),
      ],
    );
  }
}

class const _Calories({
  required final double calories,
  required final String label,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final value = NutrientPrecision.whole.format(calories);
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            value,
            style: context.appText.numberHero.copyWith(
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          Flexible(
            child: Text(
              label,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One macro: its grams in the macro's color over its name, with a dot in
/// the same color so the bar's segments can be matched to it.
class const _Macro({
  required final double grams,
  required final String name,
  required final String unit,
  required final Color color,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${NutrientPrecision.grams.format(grams)} $unit',
          style: context.appText.numberLarge.copyWith(color: color),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(color: color),
            const SizedBox(width: AppSpacing.space1),
            Text(
              name,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class const _Dot({required final Color color}) extends StatelessWidget {
  static const double _size = 8;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: _size,
    child: DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}
