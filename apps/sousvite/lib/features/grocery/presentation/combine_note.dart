import 'package:design_system/design_system.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// The merge symbol, then [text] in `on-surface-variant`: how grocery
/// items combine, in the add-to-list sheet and the breakdown dialog.
class const CombineNote({
  /// What combines, such as "Adds to ⅜ cup on your list".
  required final String text,

  /// The text's style, before its color.
  required final TextStyle? style,

  /// [bodyIconSize] or [smallIconSize], to match [style].
  required final double iconSize,
  super.key,
}) extends StatelessWidget {
  /// The icon beside body text (§7).
  static const double bodyIconSize = 20;

  /// The icon beside a small hint line, as on a status chip.
  static const double smallIconSize = 16;

  @override
  Widget build(BuildContext context) => Row(
    spacing: AppSpacing.space1,
    children: [
      Icon(
        Symbols.merge_rounded,
        size: iconSize,
        color: context.colors.primary,
      ),
      Flexible(
        child: Text(
          text,
          style: style?.copyWith(color: context.colors.onSurfaceVariant),
        ),
      ),
    ],
  );
}
