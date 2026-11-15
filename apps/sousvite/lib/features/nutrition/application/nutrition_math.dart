import 'package:domain/domain.dart';
import 'package:sousvite/features/nutrition/application/nutrient.dart';

// Stand-ins for NUT-2 in packages/nutrition (docs/BUILD_PLAN.md §6.3), which
// adds the curated density table and replaces these functions. They only
// use what a match and a food's portions already say.

/// Nutrient amounts for a whole batch or one serving.
typedef NutrientAmounts = Map<Nutrient, double>;

/// Adds up the nutrients of every matched line: each food's per-100 g
/// values scaled by the line's gram weight. Lines without a match add
/// nothing; the screen counts them separately so totals are never silently
/// low (PRD 7.4).
NutrientAmounts batchTotals(
  Iterable<NutritionMatch> matches,
  Map<FoodId, List<FoodNutrient>> nutrientsByFood,
) {
  final totals = <Nutrient, double>{};
  for (final match in matches) {
    final nutrients = nutrientsByFood[match.foodId] ?? const <FoodNutrient>[];
    for (final value in nutrients) {
      final nutrient = Nutrient.fromCode(value.nutrientCode);
      if (nutrient == null) continue;
      final amount = value.amountPer100g * match.gramWeight / 100;
      totals.update(nutrient, (sum) => sum + amount, ifAbsent: () => amount);
    }
  }
  return totals;
}

/// [batch] divided into [servings] equal servings.
NutrientAmounts perServing(NutrientAmounts batch, Quantity servings) {
  final count = servings.toDouble();
  if (count <= 0) return batch;
  return batch.map((nutrient, amount) => MapEntry(nutrient, amount / count));
}

/// How many grams [line] weighs, when it can be worked out from its unit
/// or from [portions] of the food it is matched to. Null when it can't,
/// so the user is asked for the weight instead of being shown a guess.
double? estimateGrams(IngredientLine line, List<FoodPortion> portions) {
  final quantity = line.quantity;
  if (quantity == null) return null;
  final amount = quantity.toDouble();
  final unit = line.unit;
  final gramsPerUnit = unit == null ? null : _gramsPerUnit[unit];
  if (gramsPerUnit != null) return amount * gramsPerUnit;
  final portion = portions.where((p) => p.unit == unit).firstOrNull;
  if (portion == null || portion.amount.isZero) return null;
  return amount / portion.amount.toDouble() * portion.gramWeight;
}

const Map<Unit, double> _gramsPerUnit = {
  Unit.gram: 1.0,
  Unit.kilogram: 1000.0,
  Unit.ounce: 28.349523125,
  Unit.pound: 453.59237,
};
