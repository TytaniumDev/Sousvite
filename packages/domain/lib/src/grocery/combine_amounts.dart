import 'package:units/units.dart';

/// Adds [amounts] of one grocery item together, exactly.
///
/// Amounts in the same unit add up. An amount in another unit of the same
/// family is converted into the first unit it converts to exactly
/// (2 Tbsp into ⅛ cup), so nothing is rounded. Amounts that don't convert,
/// such as grams and cups, or a count and a weight, stay separate, in the
/// order they first appear.
List<Amount> combineAmounts(Iterable<Amount> amounts) {
  final totals = <Unit?, Quantity>{};
  for (final amount in amounts) {
    final (unit, quantity) = totals.keys
        .map((unit) => (unit, _convert(amount, unit)))
        .firstWhere(
          (pair) => pair.$2 != null,
          orElse: () => (amount.unit, amount.quantity),
        );
    totals.update(
      unit,
      (total) => total + quantity!,
      ifAbsent: () => quantity!,
    );
  }
  return [
    for (final MapEntry(key: unit, value: quantity) in totals.entries)
      Amount(quantity, unit),
  ];
}

/// [amount] counted in [unit], or null when it doesn't convert exactly.
Quantity? _convert(Amount amount, Unit? unit) {
  if (amount.unit == unit) return amount.quantity;
  if (unit == null || amount.unit == null) return null;
  return amount.convertTo(unit)?.quantity;
}
