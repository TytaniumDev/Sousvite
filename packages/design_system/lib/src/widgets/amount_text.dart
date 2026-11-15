import 'package:design_system/src/theme/context_ext.dart';
import 'package:material_ui/material_ui.dart';
import 'package:units/units.dart';

/// An amount written the way recipes write it, with fraction glyphs:
/// "1 ½ cups" (DESIGN_SYSTEM.md §5.4).
///
/// The number comes from [quantity] through `QuantityFormat`. The unit word
/// is a user-facing string, so the app passes it already localized.
class const AmountText({
  /// How much: `Quantity(3, 2)` shows as "1 ½".
  required final Quantity quantity,

  /// The unit word, already localized and pluralized: "cups", "Tbsp".
  /// Null for a bare count, such as "2" eggs.
  final String? unit,

  /// What a screen reader says instead of the text: "one and a half cups".
  /// Null lets it read the text as shown.
  final String? semanticsLabel,

  /// The style of the amount. Defaults to `context.appText.amount`, which
  /// keeps the surrounding size and adds weight and tabular figures.
  final TextStyle? style,
  super.key,
}) extends StatelessWidget {
  /// The text [AmountText] shows for [quantity] and [unit], with a
  /// non-breaking space between them (DESIGN_SYSTEM.md §11).
  static String textFor(Quantity quantity, String? unit) {
    final number = quantity.format();
    return unit == null ? number : '$number $unit';
  }

  @override
  Widget build(BuildContext context) => Text(
    textFor(quantity, unit),
    semanticsLabel: semanticsLabel,
    style: style ?? context.appText.amount,
  );
}
