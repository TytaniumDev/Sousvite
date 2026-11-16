import 'package:domain/domain.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Localized unit words for the design system's amount widgets, which take
/// the word as a plain string.
extension UnitWords on AppLocalizations {
  /// The word for [unit] after [quantity]: "cup" after ½ or 1, "cups"
  /// after 2. Abbreviations ("Tbsp") never take a plural (DESIGN_SYSTEM.md
  /// §11). Null when there is no unit, for a bare count such as 2 eggs.
  String? unitWord(Unit? unit, Quantity quantity) {
    if (unit == null) return null;
    return quantity > Quantity.one
        ? common_unitOther(unit.name)
        : common_unitOne(unit.name);
  }

  /// The word after [quantity] on an ingredient line: its [unit]'s word,
  /// else its [countWord] ("clove" in "3 cloves garlic"), made plural the
  /// way English count words are ("cloves", "bunches"). Null for neither.
  String? amountWord(Unit? unit, String? countWord, Quantity quantity) =>
      unitWord(unit, quantity) ??
      (countWord == null ? null : pluralCountWord(countWord, quantity));
}

/// [word] as it reads after [quantity]: "clove" after 1 or ½, "cloves"
/// after 3, "bunches" after 2. Count words are the recipe's own text, so
/// they follow English rules rather than the app's translations.
String pluralCountWord(String word, Quantity quantity) {
  if (quantity <= Quantity.one) return word;
  return RegExp(r'(s|sh|ch|x|z)$').hasMatch(word) ? '${word}es' : '${word}s';
}
