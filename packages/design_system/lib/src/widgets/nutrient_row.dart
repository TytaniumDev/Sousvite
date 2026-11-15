import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:design_system/src/widgets/nutrition_format.dart';
import 'package:material_ui/material_ui.dart';

/// One row in the detailed nutrients table: the nutrient on the left and
/// its value right-aligned in tabular figures (DESIGN_SYSTEM.md §10.5).
///
/// Follows the theme's density, so inside `CompactDensity` the rows are
/// 40 dp tall.
class const NutrientRow({
  /// The nutrient: "Saturated fat".
  required final String label,

  /// The amount, in [unit].
  required final double value,

  /// The unit word, already localized: "g", "mg".
  required final String unit,

  /// How [value] is rounded. Grams by default; use whole numbers for
  /// calories and milligrams.
  final NutrientPrecision precision = NutrientPrecision.grams,

  /// How far the row is nested: 0 for "Fat", 1 for "Saturated fat".
  final int indent = 0,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final density = Theme.of(context).visualDensity;
    final body = context.textStyles.bodyMedium;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: kMinInteractiveDimension + density.baseSizeAdjustment.dy,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.space4 + AppSpacing.space4 * indent,
          right: AppSpacing.space4,
        ),
        child: MergeSemantics(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: body?.copyWith(
                    color: indent == 0
                        ? context.colors.onSurface
                        : context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Text(
                '${precision.format(value)} $unit',
                textAlign: TextAlign.end,
                style: context.appText.number.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
