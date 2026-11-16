import 'package:domain/domain.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Localized unit words for the design system's amount widgets, which take
/// the word as a plain string.
extension UnitWords on AppLocalizations {
  /// The word for [unit] after [quantity]: "cup" after ½ or 1, "cups"
  /// after 2. Abbreviations ("Tbsp") never take a plural (DESIGN_SYSTEM.md
  /// §11).
  ///
  /// With no unit, a line's [countWord] stands in for it, pluralized the
  /// same way: "clove" after 1, "cloves" after 2. Null when there is
  /// neither, for a bare count such as 2 eggs.
  String? unitWord(Unit? unit, Quantity quantity, {String? countWord}) {
    final plural = quantity > Quantity.one;
    if (unit != null) {
      return plural ? common_unitOther(unit.name) : common_unitOne(unit.name);
    }
    if (countWord == null) return null;
    return plural ? pluralOf(countWord) : countWord;
  }
}
