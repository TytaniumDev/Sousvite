import 'package:units/units.dart';

/// Adds [amounts] of one grocery item together, exactly.
///
/// Amounts that convert into each other exactly (the same unit family,
/// such as tablespoons and cups) add up in the largest unit among them, so
/// 2 Tbsp and ¼ cup make ⅜ cup and nothing is rounded. Amounts that don't
/// convert, such as grams and cups, or a count and a weight, stay
/// separate, in the order they first appear.
List<Amount> combineAmounts(Iterable<Amount> amounts) {
  final largest = <Object?, Unit>{};
  for (final Amount(:unit) in amounts) {
    if (unit == null) continue;
    final current = largest[_group(unit)];
    if (current == null || unit.baseUnits > current.baseUnits) {
      largest[_group(unit)] = unit;
    }
  }
  final totals = <Unit?, Quantity>{};
  for (final amount in amounts) {
    final unit = amount.unit;
    final target = unit == null ? null : largest[_group(unit)];
    final quantity = target == null
        ? amount.quantity
        : amount.convertTo(target)!.quantity;
    totals.update(
      target,
      (total) => total + quantity,
      ifAbsent: () => quantity,
    );
  }
  return [
    for (final MapEntry(key: unit, value: quantity) in totals.entries)
      Amount(quantity, unit),
  ];
}

/// What [unit] adds up with: its family, or itself for a count unit, which
/// converts only to itself.
Object _group(Unit unit) => unit.family == .count ? unit : unit.family;
