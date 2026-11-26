import 'package:design_system/src/tokens/radii.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:design_system/src/widgets/padded_ink_well.dart';
import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

/// An amount with [padding] on each side: plain, or as a button inside its
/// ink when [onTap] is set (DESIGN_SYSTEM.md §6.5).
///
/// Internal: `IngredientRow` and `GroceryItemRow` use it, so a tappable
/// amount looks and behaves the same in both. Plain amounts keep the same
/// space at their sides, so tappable and plain amounts line up in a list.
///
/// The ink is left out of the semantics tree, because the rows merge their
/// semantics and have their own tap. Screen readers get a custom action
/// named [tapLabel] instead.
class const TappableAmount({
  /// Called when the amount is tapped. Null leaves it as plain text.
  required final VoidCallback? onTap,

  /// What tapping does, as a screen reader action. Set with [onTap].
  required final String? tapLabel,

  /// The amount.
  required final Widget child,

  /// Which side the ink hugs when the amount has more room than it needs.
  final AlignmentDirectional alignment = AlignmentDirectional.centerStart,
  super.key,
}) extends StatelessWidget {
  /// The space between the amount and the edge of its ink, on every side.
  static const double padding = AppSpacing.space2;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    final tapLabel = this.tapLabel;
    if (onTap == null || tapLabel == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: padding),
        child: child,
      );
    }
    return Semantics(
      customSemanticsActions: {CustomSemanticsAction(label: tapLabel): onTap},
      // Loose, so the ink hugs the amount instead of filling the space.
      child: Align(
        alignment: alignment,
        widthFactor: 1,
        heightFactor: 1,
        child: PaddedInkWell(
          onTap: onTap,
          horizontal: padding,
          vertical: padding,
          borderRadius: AppRadii.borderSm,
          tapTargetAlignment: alignment,
          excludeFromSemantics: true,
          child: child,
        ),
      ),
    );
  }
}
