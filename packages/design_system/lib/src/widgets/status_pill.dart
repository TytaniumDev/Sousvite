import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/tokens/radii.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:material_ui/material_ui.dart';

/// A small icon and word on a colored fill, the shape every status chip and
/// badge shares (DESIGN_SYSTEM.md §9.2).
///
/// Internal: `MatchStatusChip`, `ShareBadge`, `ExperimentBadge` and
/// `ProBadge` pick the colors and icon, so each meaning keeps one look.
class const StatusPill({
  /// The icon in front of [label].
  required final IconData icon,

  /// The word, already localized.
  required final String label,

  /// The fill.
  required final Color background,

  /// The icon and text color, an `on-` role of [background].
  required final Color foreground,
  super.key,
}) extends StatelessWidget {
  /// The icon size, small enough to sit on a label line.
  static const double iconSize = 16;

  @override
  Widget build(BuildContext context) => DecoratedBox(
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
        mainAxisSize: .min,
        children: [
          Icon(icon, size: iconSize, color: foreground),
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
