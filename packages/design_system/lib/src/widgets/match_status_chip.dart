import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/tokens/radii.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// Where an ingredient's nutrition came from.
enum MatchStatus() {
  /// Matched to a USDA food.
  usda,

  /// Matched to an Open Food Facts product.
  openFoodFacts,

  /// The user picked or changed the match.
  edited,

  /// No match, so the ingredient is left out of the totals.
  notMatched,
}

/// Where an ingredient's nutrition came from, as an icon and a word on a
/// colored fill (DESIGN_SYSTEM.md §9.2).
///
/// It shows status and is not tappable; the row it sits in handles taps.
/// USDA and Open Food Facts are neutral, Edited is sage, and Not matched is
/// a warning, never an error (§4.4).
class const MatchStatusChip({
  /// The status to show.
  required final MatchStatus status,

  /// The word for [status], already localized: "USDA", "Not matched".
  required final String label,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final appColors = context.appColors;
    final (background, foreground, icon) = switch (status) {
      .usda => (
        colors.surfaceContainerHigh,
        colors.onSurface,
        Symbols.database_rounded,
      ),
      .openFoodFacts => (
        colors.surfaceContainerHigh,
        colors.onSurface,
        Symbols.barcode_rounded,
      ),
      .edited => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
        Symbols.edit_rounded,
      ),
      .notMatched => (
        appColors.warningContainer,
        appColors.onWarningContainer,
        Symbols.warning_rounded,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.borderSm,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space2,
          vertical: AppSpacing.space1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: _iconSize, color: foreground),
            const SizedBox(width: AppSpacing.space1),
            Flexible(
              child: Text(
                label,
                style: context.textStyles.labelMedium?.copyWith(
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const double _iconSize = 16;
}
