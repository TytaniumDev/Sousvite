import 'package:domain/domain.dart';
import 'package:nutrition/nutrition.dart' as nutrition;
import 'package:sousvite/features/nutrition/application/nutrient.dart';

/// Nutrient amounts for a whole batch or one serving.
typedef NutrientAmounts = Map<Nutrient, double>;

/// Adds up the nutrients of every matched line with `nutrition`'s
/// [nutrition.batchTotals], keeping the nutrients the app shows. Lines
/// without a match add nothing; the screen counts them separately so totals
/// are never silently low (PRD 7.4).
NutrientAmounts batchTotals(
  Iterable<NutritionMatch> matches,
  Map<FoodId, List<FoodNutrient>> nutrientsByFood,
) {
  final totals = nutrition.batchTotals([
    for (final match in matches)
      (
        grams: match.gramWeight,
        nutrients: nutrientsByFood[match.foodId] ?? const <FoodNutrient>[],
      ),
  ]);
  return _shown(totals);
}

/// The nutrients in [grams] of one food with these [nutrients] per 100 g,
/// such as one label serving of a scanned product.
NutrientAmounts nutrientsIn(double grams, List<FoodNutrient> nutrients) =>
    _shown(nutrition.batchTotals([(grams: grams, nutrients: nutrients)]));

/// The [totals], keyed by USDA nutrient number, that the app shows.
NutrientAmounts _shown(Map<String, double> totals) => {
  for (final MapEntry(:key, :value) in totals.entries)
    ?Nutrient.fromCode(key): value,
};

/// [batch] divided into [servings] equal servings.
NutrientAmounts perServing(NutrientAmounts batch, Quantity servings) =>
    nutrition.perServing(batch, servings);

/// How many grams [line] weighs as a food with these [portions] and
/// [foodName], from [nutrition.gramWeight]. A volume the portions don't
/// cover uses the density of the food, else of the line's ingredient. Null
/// when it can't be worked out, so the user is asked for the weight
/// instead of being shown a guess.
double? estimateGrams(
  IngredientLine line,
  List<FoodPortion> portions, {
  String? foodName,
}) {
  final quantity = line.quantity;
  if (quantity == null) return null;
  return nutrition.gramWeight(
    Amount(quantity, line.unit),
    portions: portions,
    density:
        (foodName == null ? null : nutrition.densityOf(foodName)) ??
        nutrition.densityOf(line.name ?? line.rawText),
  );
}
