import 'package:domain/domain.dart';

/// A matched ingredient line: how much it weighs and its food's nutrients
/// per 100 g.
typedef WeighedFood = ({double grams, List<FoodNutrient> nutrients});

/// Nutrient amounts by USDA nutrient number (`FoodNutrient.nutrientCode`).
typedef NutrientTotals = Map<String, double>;

/// The whole batch's nutrients: each food's per-100 g values scaled by its
/// line's weight, added up (ENGINEERING.md §11.2).
///
/// Lines without a match aren't passed in; callers count them separately
/// so totals are never silently low (PRD 7.4).
NutrientTotals batchTotals(Iterable<WeighedFood> foods) {
  final totals = <String, double>{};
  for (final (:grams, :nutrients) in foods) {
    for (final nutrient in nutrients) {
      final amount = nutrient.amountPer100g * grams / 100;
      totals.update(
        nutrient.nutrientCode,
        (sum) => sum + amount,
        ifAbsent: () => amount,
      );
    }
  }
  return totals;
}

/// One serving of [batch] when it's divided into [servings], each user's
/// own serving size. A non-positive [servings] returns [batch] unchanged.
Map<K, double> perServing<K>(Map<K, double> batch, Quantity servings) {
  final count = servings.toDouble();
  if (count <= 0) return batch;
  return batch.map((key, amount) => MapEntry(key, amount / count));
}
