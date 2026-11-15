/// The unit a nutrient is measured in.
enum NutrientUnit() {
  kilocalorie,
  gram,
  milligram,
  microgram,
}

/// The nutrients the app shows, in table order (PRD 7.4), with their USDA
/// nutrient numbers. Open Food Facts values are stored under the same
/// numbers (`FoodNutrient.nutrientCode`).
enum Nutrient(
  /// USDA FoodData Central nutrient number.
  final String code,

  /// The unit values are in, per 100 g of food.
  final NutrientUnit unit, {

  /// Shown indented under this nutrient, such as sugars under carbs.
  final Nutrient? parent,
}) {
  calories('208', .kilocalorie),
  fat('204', .gram),
  saturatedFat('606', .gram, parent: fat),
  transFat('605', .gram, parent: fat),
  cholesterol('601', .milligram),
  sodium('307', .milligram),
  carbs('205', .gram),
  fiber('291', .gram, parent: carbs),
  sugars('269', .gram, parent: carbs),
  protein('203', .gram),
  vitaminD('328', .microgram),
  calcium('301', .milligram),
  iron('303', .milligram),
  potassium('306', .milligram),
  vitaminA('320', .microgram),
  vitaminC('401', .milligram);

  /// The nutrient with USDA number [code], or null if the app doesn't show
  /// it.
  static Nutrient? fromCode(String code) =>
      values.where((nutrient) => nutrient.code == code).firstOrNull;
}
