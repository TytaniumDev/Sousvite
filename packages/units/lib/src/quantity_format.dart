import 'package:units/src/quantity.dart';

/// Formats a [Quantity] the way recipes write it, with fraction glyphs:
/// 1 ½, ¾, 2 (DESIGN_SYSTEM.md §5.4).
///
/// Only the number is formatted. Unit words ("cups", "Tbsp") are
/// user-facing strings, so the app localizes them.
extension QuantityFormat on Quantity {
  /// The quantity as it reads on screen: `1 ½`, `⅓`, `12`.
  ///
  /// Fractions with a glyph in our font (halves, thirds, quarters, and
  /// eighths) use it. Others fall back to `5/16`, and a whole part is
  /// separated from its fraction by a space.
  String format() {
    if (isNegative) return '−${(-this).format()}';
    final whole = wholePart;
    final fraction = fractionalPart;
    if (fraction.isZero) return '$whole';
    final glyph =
        _glyphs[(fraction.numerator, fraction.denominator)] ??
        '${fraction.numerator}/${fraction.denominator}';
    return whole == 0 ? glyph : '$whole $glyph';
  }
}

/// The fraction glyphs Plus Jakarta Sans has (DESIGN_SYSTEM.md §5.1).
const _glyphs = <(int, int), String>{
  (1, 2): '½',
  (1, 3): '⅓',
  (2, 3): '⅔',
  (1, 4): '¼',
  (3, 4): '¾',
  (1, 8): '⅛',
  (3, 8): '⅜',
  (5, 8): '⅝',
  (7, 8): '⅞',
};
