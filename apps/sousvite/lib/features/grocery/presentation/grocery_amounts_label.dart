import 'package:design_system/design_system.dart';
import 'package:sousvite/features/grocery/application/grocery_entry.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/units/unit_words.dart';

/// [amounts] as one line of text, joined with plus signs: "⅜ cup + 200 g".
/// Empty when there are none.
String groceryAmountsLabel(
  AppLocalizations l10n,
  Iterable<GroceryAmount> amounts,
) => amounts
    .map(
      (amount) => AmountText.textFor(
        amount.quantity,
        l10n.unitWord(
          amount.unit,
          amount.quantity,
          countWord: amount.countWord,
        ),
      ),
    )
    .join(' + ');
