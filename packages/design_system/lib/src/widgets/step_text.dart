import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/widgets/amount_text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:units/units.dart';

/// One part of a step's text: plain words or an amount placed inline.
///
/// `packages/measuring` finds the amounts (smart step text); the feature
/// maps its result to these segments.
@immutable
sealed class const StepSegment();

/// Plain words in a step.
final class const StepTextSegment(
  /// The words, including any spaces around them.
  final String text,
) extends StepSegment {
  @override
  bool operator ==(Object other) =>
      other is StepTextSegment && other.text == text;

  @override
  int get hashCode => text.hashCode;
}

/// An amount placed inline in a step: "Whisk in **¾ cup** sugar".
/// Written the same way as [AmountText].
final class const StepAmountSegment({
  /// How much.
  required final Quantity quantity,

  /// The unit word, already localized: "cup". Null for a bare count.
  final String? unit,

  /// What a screen reader says instead: "three quarters cup". Null reads
  /// the text as shown.
  final String? semanticsLabel,
}) extends StepSegment {
  @override
  bool operator ==(Object other) =>
      other is StepAmountSegment &&
      other.quantity == quantity &&
      other.unit == unit &&
      other.semanticsLabel == semanticsLabel;

  @override
  int get hashCode => Object.hash(quantity, unit, semanticsLabel);
}

/// A step's text with its amounts bold and in `primary`
/// (DESIGN_SYSTEM.md §9.2).
///
/// In the editor, set [highlightAmounts] so each placed amount sits on a
/// `primary-container` highlight and is easy to spot and correct. Cooking
/// mode leaves it off and passes the cooking styles.
class const StepText({
  /// The step, in order.
  required final List<StepSegment> segments,

  /// The style of the words. Defaults to `bodyLarge`; cooking mode passes
  /// `context.appText.cookingStep`.
  final TextStyle? style,

  /// The style of the amounts. Defaults to `context.appText.amount`;
  /// cooking mode passes `context.appText.cookingAmount`. The color always
  /// comes from the theme.
  final TextStyle? amountStyle,

  /// Whether amounts get a `primary-container` highlight behind them.
  final bool highlightAmounts = false,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final placed = (amountStyle ?? context.appText.amount).copyWith(
      color: colors.primary,
      backgroundColor: highlightAmounts ? colors.primaryContainer : null,
    );
    return Text.rich(
      TextSpan(
        children: [
          for (final segment in segments)
            switch (segment) {
              StepTextSegment(:final text) => TextSpan(text: text),
              StepAmountSegment(
                :final quantity,
                :final unit,
                :final semanticsLabel,
              ) =>
                TextSpan(
                  text: AmountText.textFor(quantity, unit),
                  semanticsLabel: semanticsLabel,
                  style: placed,
                ),
            },
        ],
      ),
      style: style ?? context.textStyles.bodyLarge,
    );
  }
}
