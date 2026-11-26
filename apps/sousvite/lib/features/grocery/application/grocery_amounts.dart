import 'package:domain/domain.dart';
import 'package:sousvite/features/grocery/application/grocery_entry.dart';

/// [items]' amounts added up, one per unit or count word, in the order they
/// first appear (PRD 7.7). Items without an amount are left out.
///
/// Items with a count word ("3 cloves garlic") add up only with the same
/// word. The rest add up exactly in the largest unit of each family by
/// [combineAmounts], so 2 Tbsp and ¼ cup make ⅜ cup.
///
/// When that still leaves amounts that measure different things, such as
/// cups and grams, and [gramsOf] knows every one's weight, they become one
/// amount in the largest unit among them: the one that weighs the most,
/// so cups of sugar win over grams. That total is rounded to something
/// you can measure and marked approximate.
List<GroceryAmount> groceryAmounts(
  Iterable<GroceryItem> items, {
  double? Function(GroceryItem item)? gramsOf,
}) {
  final byCountWord = <String?, List<GroceryItem>>{};
  for (final item in items) {
    if (item.quantity != null) (byCountWord[item.countWord] ??= []).add(item);
  }
  return [
    for (final MapEntry(key: countWord, value: items) in byCountWord.entries)
      for (final (amount, approximate) in _combine(items, countWord, gramsOf))
        (
          quantity: amount.quantity,
          unit: amount.unit,
          countWord: countWord,
          approximate: approximate,
        ),
  ];
}

Iterable<(Amount, bool)> _combine(
  List<GroceryItem> items,
  String? countWord,
  double? Function(GroceryItem item)? gramsOf,
) {
  final amounts = [for (final item in items) Amount(item.quantity!, item.unit)];
  final exact = combineAmounts(amounts);
  if (exact.length < 2 || countWord != null || gramsOf == null) {
    return [for (final amount in exact) (amount, false)];
  }
  final grams = [for (final item in items) gramsOf(item)];
  if (grams.any((weight) => weight == null || weight <= 0)) {
    return [for (final amount in exact) (amount, false)];
  }
  final weights = [
    for (final (index, amount) in amounts.indexed) (amount, grams[index]!),
  ];
  final total = weights.fold<double>(0, (sum, weight) => sum + weight.$2);
  final (target, gramsPerUnit) = exact
      .map((amount) => (amount.unit, _gramsPerUnit(amount.unit, weights)))
      .reduce((a, b) => b.$2 > a.$2 ? b : a);
  return [(measurableAmount(total / gramsPerUnit, target), true)];
}

/// How much one [unit] of the item weighs, from the [weights] of the
/// amounts that measure the same thing. Without a unit, the weight of one.
double _gramsPerUnit(Unit? unit, List<(Amount, double)> weights) {
  var count = 0.0;
  var grams = 0.0;
  for (final (amount, weight) in weights) {
    final inUnit = unit == null
        ? (amount.unit == null ? amount.quantity.toDouble() : null)
        : amount.approximateValueIn(unit);
    if (inUnit == null) continue;
    count += inUnit;
    grams += weight;
  }
  return grams / count;
}
