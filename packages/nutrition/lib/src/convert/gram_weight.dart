import 'package:domain/domain.dart';

/// How many grams [amount] of a food weighs, or null when it can't be
/// worked out, so the user is asked instead of shown a guess
/// (ENGINEERING.md §11.2).
///
/// - A weight converts directly.
/// - A volume uses the food's [portions] that measure a volume, preferring
///   one in the same unit, then [density] in grams per milliliter (from
///   `densityOf`).
/// - A count ("2 eggs", "1 piece") uses a portion in the same unit, or a
///   portion with no unit, which USDA uses for "1 large egg".
double? gramWeight(
  Amount amount, {
  List<FoodPortion> portions = const [],
  double? density,
}) {
  final unit = amount.unit;
  if (unit != null && unit.dimension == .mass) {
    return amount.approximateValueIn(Unit.gram);
  }
  if (unit != null && unit.dimension == .volume) {
    return _fromPortions(amount, _volumePortions(unit, portions)) ??
        _fromDensity(amount, density);
  }
  return _fromPortions(amount, [
    ...portions.where((portion) => portion.unit == unit),
    ...portions.where((portion) => portion.unit == null),
  ]);
}

/// Portions that measure a volume, the ones in [unit] first.
List<FoodPortion> _volumePortions(Unit unit, List<FoodPortion> portions) {
  final volumes = portions.where(
    (portion) => portion.unit?.dimension == .volume,
  );
  return [
    ...volumes.where((portion) => portion.unit == unit),
    ...volumes.where((portion) => portion.unit != unit),
  ];
}

double? _fromPortions(Amount amount, List<FoodPortion> portions) {
  for (final portion in portions) {
    if (portion.amount.isZero) continue;
    final count = switch (portion.unit) {
      final unit? when amount.unit != null && amount.unit != unit =>
        amount.approximateValueIn(unit),
      _ => amount.quantity.toDouble(),
    };
    if (count == null) continue;
    return count / portion.amount.toDouble() * portion.gramWeight;
  }
  return null;
}

double? _fromDensity(Amount amount, double? density) {
  if (density == null) return null;
  final milliliters = amount.approximateValueIn(Unit.milliliter);
  return milliliters == null ? null : milliliters * density;
}
