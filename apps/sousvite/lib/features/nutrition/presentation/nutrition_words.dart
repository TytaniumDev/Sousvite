import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:sousvite/features/nutrition/application/nutrient.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Localized words for the nutrition screens.
extension NutritionWords on AppLocalizations {
  /// The words [MacroSummary] shows next to its numbers.
  MacroLabels get macroLabels => MacroLabels(
    calories: nutrition_calories,
    protein: nutrition_protein,
    carbs: nutrition_carbs,
    fat: nutrition_fat,
    grams: nutrition_unitGrams,
  );

  /// What the numbers cover: "Per serving (1 of 4)" or "Whole batch".
  String basisLabel(NutritionBasis basis, Quantity servings) => switch (basis) {
    .perServing => nutrition_perServingOf(servings.format()),
    .batch => nutrition_wholeBatch,
  };

  /// The nutrient's name in the detailed table.
  String nutrientName(Nutrient nutrient) => switch (nutrient) {
    .calories => nutrition_calories,
    .fat => nutrition_fat,
    .saturatedFat => nutrition_saturatedFat,
    .transFat => nutrition_transFat,
    .cholesterol => nutrition_cholesterol,
    .sodium => nutrition_sodium,
    .carbs => nutrition_carbs,
    .fiber => nutrition_fiber,
    .sugars => nutrition_sugars,
    .protein => nutrition_protein,
    .vitaminD => nutrition_vitaminD,
    .calcium => nutrition_calcium,
    .iron => nutrition_iron,
    .potassium => nutrition_potassium,
    .vitaminA => nutrition_vitaminA,
    .vitaminC => nutrition_vitaminC,
  };

  /// The unit word after a nutrient's value.
  String nutrientUnit(NutrientUnit unit) => switch (unit) {
    .kilocalorie => nutrition_unitKilocalories,
    .gram => nutrition_unitGrams,
    .milligram => nutrition_unitMilligrams,
    .microgram => nutrition_unitMicrograms,
  };

  /// The word on a [MatchStatusChip].
  String matchStatus(MatchStatus status) => switch (status) {
    .usda => nutrition_sourceUsda,
    .openFoodFacts => nutrition_sourceOpenFoodFacts,
    .edited => nutrition_edited,
    .notMatched => nutrition_notMatched,
  };
}

/// Where [match]'s nutrition came from, for its [MatchStatusChip].
MatchStatus matchStatusOf(NutritionMatch? match) => switch (match) {
  null => .notMatched,
  NutritionMatch(userConfirmed: true) => .edited,
  NutritionMatch(:final source) => matchStatusOfSource(source),
};

/// The [MatchStatusChip] status for nutrition from [source].
MatchStatus matchStatusOfSource(NutritionSource source) => switch (source) {
  .openFoodFacts => .openFoodFacts,
  .usda => .usda,
};
