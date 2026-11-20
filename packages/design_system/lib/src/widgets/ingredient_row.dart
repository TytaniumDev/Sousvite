import 'dart:math' as math;

import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/tokens/motion.dart';
import 'package:design_system/src/tokens/radii.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:design_system/src/widgets/amount_text.dart';
import 'package:design_system/src/widgets/padded_ink_well.dart';
import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:units/units.dart';

/// What ticking an [IngredientRow]'s checkbox means.
enum IngredientCheckStyle() {
  /// Done with it, as while cooking: a checked line fades and is struck
  /// through (§8.2).
  checkOff,

  /// Picked, as when choosing lines to add to the grocery list: the text
  /// stays as it is whether checked or not.
  select,
}

/// One ingredient line: amount column, name, and preparation note, with an
/// optional checkbox (DESIGN_SYSTEM.md §9.2).
///
/// Rows follow the theme's density, so wrapping a list in `CompactDensity`
/// makes its rows compact (§6.2). Without [onChanged] the row is
/// read-only. With [onChanged] the whole row toggles [checked] and is
/// 56 dp tall, or 48 dp when compact. With [IngredientCheckStyle.checkOff]
/// a checked line fades to `on-surface-variant` and is struck through
/// (§8.2); with [IngredientCheckStyle.select] the checkbox alone shows the
/// choice.
///
/// A [guide] sits under the name, such as the `MeasuringGuide` cooking
/// mode shows for the amount.
///
/// With [onAmountTap] the amount itself is a button with a 48 dp hit area,
/// apart from the row's checkbox: tapping it can show the amount another
/// way, such as garlic cloves as teaspoons of jarred garlic. Its ink sits
/// [amountPadding] around the amount on every side. Every amount keeps
/// that space at its start, so tappable and plain amounts line up. Screen
/// readers offer it as a custom action named [amountTapLabel].
class const IngredientRow({
  /// The ingredient: "flour".
  required final String name,

  /// How much, or null when the line has no amount ("salt to taste").
  final Quantity? quantity,

  /// The unit word, already localized: "cups". Null for a bare count.
  final String? unit,

  /// What a screen reader says for the amount: "two and a quarter cups".
  /// Null reads it as shown.
  final String? amountSemanticsLabel,

  /// How it is prepared: "sifted", "finely chopped".
  final String? preparation,

  /// Whether the line is checked off. Shows a checkbox when [onChanged] is
  /// set.
  final bool checked = false,

  /// Called with the new value when the row is tapped. Null for a
  /// read-only row with no checkbox.
  final ValueChanged<bool>? onChanged,

  /// What [checked] means, and so whether a checked line is struck
  /// through.
  final IngredientCheckStyle checkStyle = .checkOff,

  /// Shown under the name and preparation, such as a `MeasuringGuide`.
  /// Null shows nothing.
  final Widget? guide,

  /// Called when the amount is tapped. Null leaves the amount as plain
  /// text. Needs [amountTapLabel].
  final VoidCallback? onAmountTap,

  /// What tapping the amount does, as a screen reader action: "Show as
  /// jarred garlic". Set with [onAmountTap].
  final String? amountTapLabel,
  super.key,
}) extends StatelessWidget {
  /// The narrowest the amount column gets, so names line up in a list.
  static const double amountColumnWidth = 96;

  /// The space between a tappable amount and the edge of its ink, on every
  /// side. Plain amounts keep it on the left and right too, so they line
  /// up with tappable ones.
  static const double amountPadding = AppSpacing.space2;

  /// The space between the amount's ink and the name.
  static const double amountGap = AppSpacing.space1;

  // The space between the row's edge and its content, which is the ink's
  // padding when the row is tappable. The name keeps 8 dp above and below
  // either way.
  static const double _rowPadding = AppSpacing.space4;

  /// The height of a row with a checkbox at standard density (§6.2).
  static const double interactiveMinHeight = 56;

  static final _fade = SpringCurve(AppMotion.effectsDefault);

  @override
  Widget build(BuildContext context) {
    assert(
      (onAmountTap == null) == (amountTapLabel == null),
      'A tappable amount needs its screen reader label.',
    );
    final colors = context.colors;
    final body = context.textStyles.bodyLarge!;
    final checkedOff = checked && checkStyle == .checkOff;
    final color = checkedOff ? colors.onSurfaceVariant : colors.onSurface;
    final decoration = checkedOff ? TextDecoration.lineThrough : null;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _fade.duration;
    final onChanged = this.onChanged;
    final density = Theme.of(context).visualDensity;
    final minHeight =
        (onChanged == null ? kMinInteractiveDimension : interactiveMinHeight) +
        density.baseSizeAdjustment.dy;

    // A tappable row's ink keeps 4 dp above and below its content.
    final inkVertical = onChanged == null ? 0.0 : PaddedInkWell.minPadding;
    final content = AnimatedDefaultTextStyle(
      duration: duration,
      curve: _fade,
      style: body.copyWith(color: color, decoration: decoration),
      child: Row(
        children: [
          if (onChanged != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.space2),
              child: Checkbox(
                value: checked,
                onChanged: (value) => onChanged(value ?? false),
                // The whole row takes the tap, so the box needs no hit area
                // of its own around it.
                materialTapTargetSize: .shrinkWrap,
              ),
            ),
          _AmountColumn(
            quantity: quantity,
            unit: unit,
            semanticsLabel: amountSemanticsLabel,
            onTap: onAmountTap,
            tapLabel: amountTapLabel,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.space2 - inkVertical,
              ),
              child: _NameAndGuide(
                name: name,
                preparation: preparation,
                guide: guide,
              ),
            ),
          ),
        ],
      ),
    );

    final constraints = BoxConstraints(minHeight: minHeight);
    if (onChanged == null) {
      return ConstrainedBox(
        constraints: constraints,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _rowPadding),
          child: content,
        ),
      );
    }
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: constraints,
        child: PaddedInkWell(
          onTap: () => onChanged(!checked),
          horizontal: _rowPadding,
          child: content,
        ),
      ),
    );
  }
}

/// The amount column. It is at least [IngredientRow.amountColumnWidth]
/// wide so names line up across rows, but never more than 40% of the row,
/// so large text still leaves room for the name.
class const _AmountColumn({
  required final Quantity? quantity,
  required final String? unit,
  required final String? semanticsLabel,
  required final VoidCallback? onTap,
  required final String? tapLabel,
}) extends StatelessWidget {
  static const _maxShare = 0.4;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final max = constraints.maxWidth * _maxShare;
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: math.min(IngredientRow.amountColumnWidth, max),
          maxWidth: max,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            end: IngredientRow.amountGap,
          ),
          child: _TappableAmount(
            onTap: onTap,
            tapLabel: tapLabel,
            child: _Amount(
              quantity: quantity,
              unit: unit,
              semanticsLabel: semanticsLabel,
            ),
          ),
        ),
      );
    },
  );
}

/// The amount with [IngredientRow.amountPadding] on each side: plain, or
/// as a button inside its ink when [onTap] is set.
///
/// The ink is left out of the semantics tree, because a row with a
/// checkbox merges its semantics and has its own tap. Screen readers get
/// a custom action named [tapLabel] instead.
class const _TappableAmount({
  required final VoidCallback? onTap,
  required final String? tapLabel,
  required final Widget child,
}) extends StatelessWidget {
  static const double _padding = IngredientRow.amountPadding;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    final tapLabel = this.tapLabel;
    if (onTap == null || tapLabel == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: _padding),
        child: child,
      );
    }
    return Semantics(
      customSemanticsActions: {CustomSemanticsAction(label: tapLabel): onTap},
      // Loose, so the ink hugs the amount instead of filling the column.
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: 1,
        heightFactor: 1,
        child: PaddedInkWell(
          onTap: onTap,
          horizontal: _padding,
          vertical: _padding,
          borderRadius: AppRadii.borderSm,
          tapTargetAlignment: AlignmentDirectional.centerStart,
          excludeFromSemantics: true,
          child: child,
        ),
      ),
    );
  }
}

class const _Amount({
  required final Quantity? quantity,
  required final String? unit,
  required final String? semanticsLabel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quantity = this.quantity;
    if (quantity == null) return const SizedBox.shrink();
    return AmountText(
      quantity: quantity,
      unit: unit,
      semanticsLabel: semanticsLabel,
    );
  }
}

class const _NameAndGuide({
  required final String name,
  required final String? preparation,
  required final Widget? guide,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final words = _NameAndPreparation(name: name, preparation: preparation);
    final guide = this.guide;
    if (guide == null) return words;
    return Column(
      crossAxisAlignment: .start,
      spacing: AppSpacing.space1,
      children: [words, guide],
    );
  }
}

class const _NameAndPreparation({
  required final String name,
  required final String? preparation,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final preparation = this.preparation;
    return Text.rich(
      TextSpan(
        text: name,
        children: [
          if (preparation != null)
            TextSpan(
              text: ', $preparation',
              style: TextStyle(color: context.colors.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
