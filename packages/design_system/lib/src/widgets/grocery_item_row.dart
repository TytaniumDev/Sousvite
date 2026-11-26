import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/tokens/motion.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:design_system/src/widgets/amount_text.dart';
import 'package:design_system/src/widgets/padded_ink_well.dart';
import 'package:design_system/src/widgets/tappable_amount.dart';
import 'package:material_ui/material_ui.dart';
import 'package:units/units.dart';

/// One grocery list item: checkbox, name, combined amount, and the recipes
/// it came from (DESIGN_SYSTEM.md §9.2, §10.6).
///
/// The whole row toggles [checked]. It uses comfortable density, at least
/// 56 dp tall. A checked item fades to `on-surface-variant` and is struck
/// through; the feature moves it into the Checked group.
///
/// With [onAmountTap] the amount is its own button with a 48 dp hit area,
/// apart from the row's tap, such as to show how much each recipe needs.
/// Its ink sits [amountPadding] around the amount, and every trailing
/// amount keeps that space at its sides, so tappable and plain amounts line
/// up. Screen readers offer it as a custom action named [amountTapLabel].
class const GroceryItemRow({
  /// The item: "flour".
  required final String name,

  /// Whether the item is checked off.
  required final bool checked,

  /// Called with the new value when the row is tapped.
  required final ValueChanged<bool> onChanged,

  /// The combined amount, or null when the item has none ("salt").
  final Quantity? quantity,

  /// The unit word, already localized: "cups". Null for a bare count.
  final String? unit,

  /// What a screen reader says for the amount: "two and a quarter cups".
  /// Null reads it as shown.
  final String? amountSemanticsLabel,

  /// Which recipes the item came from, already joined and localized:
  /// "Chili, Cornbread". Null for an item added by hand.
  final String? sourcesLabel,

  /// Called when the amount is tapped. Null leaves the amount as plain
  /// text. Needs [amountTapLabel].
  final VoidCallback? onAmountTap,

  /// What tapping the amount does, as a screen reader action: "Show
  /// amounts by recipe". Set with [onAmountTap].
  final String? amountTapLabel,
  super.key,
}) extends StatelessWidget {
  /// The smallest height of a row (§6.2).
  static const double minHeight = 56;

  /// The largest share of the row a trailing amount takes, so the name
  /// keeps most of the room.
  static const double maxAmountShare = 0.5;

  /// From this text scale up, the amount moves under the name, since a
  /// trailing amount would squeeze both into broken words.
  static const double stackedTextScale = 1.5;

  /// The space between a tappable amount and the edge of its ink, on every
  /// side.
  static const double amountPadding = TappableAmount.padding;

  static final _fade = SpringCurve(AppMotion.effectsDefault);

  @override
  Widget build(BuildContext context) {
    assert(
      (onAmountTap == null) == (amountTapLabel == null),
      'A tappable amount needs its screen reader label.',
    );
    final colors = context.colors;
    final body = context.textStyles.bodyLarge!;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _fade.duration;
    final fontSize = body.fontSize!;
    final stacked =
        MediaQuery.textScalerOf(context).scale(fontSize) >=
        fontSize * stackedTextScale;
    final quantity = this.quantity;
    final amount = quantity == null
        ? null
        : _Amount(
            quantity: quantity,
            unit: unit,
            semanticsLabel: amountSemanticsLabel,
          );
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: minHeight),
        child: PaddedInkWell(
          onTap: () => onChanged(!checked),
          horizontal: AppSpacing.space4,
          child: AnimatedDefaultTextStyle(
            duration: duration,
            curve: _fade,
            style: body.copyWith(
              color: checked ? colors.onSurfaceVariant : colors.onSurface,
              decoration: checked ? TextDecoration.lineThrough : null,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => Row(
                children: [
                  Checkbox(
                    value: checked,
                    onChanged: (value) => onChanged(value ?? false),
                    // The whole row takes the tap, so the box needs no hit
                    // area of its own around it.
                    materialTapTargetSize: .shrinkWrap,
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space1,
                      ),
                      child: _Details(
                        name: name,
                        amount: !stacked || amount == null
                            ? null
                            : onAmountTap == null
                            ? amount
                            : _StackedTappableAmount(
                                onTap: onAmountTap,
                                tapLabel: amountTapLabel,
                                child: amount,
                              ),
                        sourcesLabel: sourcesLabel,
                      ),
                    ),
                  ),
                  if (amount != null && !stacked)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * maxAmountShare,
                      ),
                      child: Padding(
                        // With the amount's own padding, 12 dp from the
                        // name.
                        padding: const EdgeInsets.only(left: AppSpacing.space1),
                        child: TappableAmount(
                          onTap: onAmountTap,
                          tapLabel: amountTapLabel,
                          alignment: AlignmentDirectional.centerEnd,
                          child: amount,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A tappable amount under the name, moved back by its ink's padding so
/// the text lines up with the name above it.
class const _StackedTappableAmount({
  required final VoidCallback? onTap,
  required final String? tapLabel,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final start = Directionality.of(context) == TextDirection.ltr ? -1 : 1;
    return Transform.translate(
      offset: Offset(start * TappableAmount.padding, 0),
      child: TappableAmount(onTap: onTap, tapLabel: tapLabel, child: child),
    );
  }
}

/// The amount in the row's current text style, so it fades and strikes
/// through with the name.
class const _Amount({
  required final Quantity quantity,
  required final String? unit,
  required final String? semanticsLabel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AmountText(
    quantity: quantity,
    unit: unit,
    semanticsLabel: semanticsLabel,
    style: DefaultTextStyle.of(context).style,
  );
}

class const _Details({
  required final String name,
  required final Widget? amount,
  required final String? sourcesLabel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final amount = this.amount;
    final sourcesLabel = this.sourcesLabel;
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        Text(name),
        ?amount,
        if (sourcesLabel != null)
          Text(
            sourcesLabel,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              decoration: TextDecoration.none,
            ),
          ),
      ],
    );
  }
}
