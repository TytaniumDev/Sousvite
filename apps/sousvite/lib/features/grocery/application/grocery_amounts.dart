import 'package:domain/domain.dart';
import 'package:sousvite/features/grocery/application/grocery_entry.dart';

/// [items]' amounts added up, one per unit or count word, in the order they
/// first appear. Items with a count word ("3 cloves garlic") add up only
/// with the same word; the rest by [combineAmounts]. Items without an
/// amount are left out.
List<GroceryAmount> groceryAmounts(Iterable<GroceryItem> items) {
  final byCountWord = <String?, List<Amount>>{};
  for (final item in items) {
    if (item.quantity case final quantity?) {
      (byCountWord[item.countWord] ??= []).add(Amount(quantity, item.unit));
    }
  }
  return [
    for (final MapEntry(key: countWord, value: amounts) in byCountWord.entries)
      for (final amount in combineAmounts(amounts))
        (quantity: amount.quantity, unit: amount.unit, countWord: countWord),
  ];
}
