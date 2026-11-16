import 'package:data/src/app_database.dart';
import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

/// Reads a [Food] from its row.
extension FoodRowMapping on FoodRow {
  /// The entity this row stores.
  Food toEntity() => Food(
    id: FoodId(id),
    source: source,
    externalId: externalId,
    name: name,
    brand: brand,
  );
}

/// Writes a [Food] as a row.
extension FoodCompanionMapping on Food {
  /// A row with every column set.
  FoodsCompanion toCompanion() => FoodsCompanion.insert(
    id: id.value,
    source: source,
    externalId: externalId,
    name: name,
    brand: Value(brand),
  );
}

/// Reads a [FoodNutrient] from its row.
extension FoodNutrientRowMapping on FoodNutrientRow {
  /// The entity this row stores.
  FoodNutrient toEntity() => FoodNutrient(
    foodId: FoodId(foodId),
    nutrientCode: nutrientCode,
    amountPer100g: amountPer100g,
  );
}

/// Writes a [FoodNutrient] as a row.
extension FoodNutrientCompanionMapping on FoodNutrient {
  /// A row with every column set.
  FoodNutrientsCompanion toCompanion() => FoodNutrientsCompanion.insert(
    foodId: foodId.value,
    nutrientCode: nutrientCode,
    amountPer100g: amountPer100g,
  );
}

/// Reads a [FoodPortion] from its row.
extension FoodPortionRowMapping on FoodPortionRow {
  /// The entity this row stores.
  FoodPortion toEntity() => FoodPortion(
    id: FoodPortionId(id),
    foodId: FoodId(foodId),
    amount: Quantity(amountNumerator, amountDenominator),
    gramWeight: gramWeight,
    unit: unit,
    description: description,
  );
}

/// Writes a [FoodPortion] as a row.
extension FoodPortionCompanionMapping on FoodPortion {
  /// A row with every column set.
  FoodPortionsCompanion toCompanion() => FoodPortionsCompanion.insert(
    id: id.value,
    foodId: foodId.value,
    amountNumerator: amount.numerator,
    amountDenominator: amount.denominator,
    gramWeight: gramWeight,
    unit: Value(unit),
    description: Value(description),
  );
}

/// Reads a [NutritionMatch] from its row.
extension NutritionMatchRowMapping on NutritionMatchRow {
  /// The entity this row stores.
  NutritionMatch toEntity() => NutritionMatch(
    id: NutritionMatchId(id),
    ingredientLineId: IngredientLineId(ingredientLineId),
    foodId: FoodId(foodId),
    source: source,
    gramWeight: gramWeight,
    userConfirmed: userConfirmed,
  );
}

/// Writes a [NutritionMatch] as a row.
extension NutritionMatchCompanionMapping on NutritionMatch {
  /// A row with every column set.
  NutritionMatchesCompanion toCompanion() => NutritionMatchesCompanion.insert(
    id: id.value,
    ingredientLineId: ingredientLineId.value,
    foodId: foodId.value,
    source: source,
    gramWeight: gramWeight,
    userConfirmed: Value(userConfirmed),
  );
}
