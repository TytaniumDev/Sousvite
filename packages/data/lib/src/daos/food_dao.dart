import 'package:data/src/app_database.dart';
import 'package:data/src/foods/food_search.dart';
import 'package:data/src/tables/food_tables.dart';
import 'package:data/src/tables/recipe_tables.dart';
import 'package:drift/drift.dart';

part 'food_dao.g.dart';

/// Queries for cached foods and nutrition matches.
@DriftAccessor(
  tables: [
    Foods,
    FoodNutrients,
    FoodPortions,
    NutritionMatches,
    IngredientLines,
  ],
)
class FoodDao(super.attachedDatabase)
    extends DatabaseAccessor<AppDatabase>
    with _$FoodDaoMixin {
  /// The cached food with [id].
  Selectable<FoodRow> food(String id) =>
      select(foods)..where((row) => row.id.equals(id));

  /// The nutrients of the cached food [foodId].
  Selectable<FoodNutrientRow> nutrientsOf(String foodId) =>
      select(foodNutrients)
        ..where((row) => row.foodId.equals(foodId))
        ..orderBy([(row) => OrderingTerm.asc(row.nutrientCode)]);

  /// The portions of the cached food [foodId].
  Selectable<FoodPortionRow> portionsOf(String foodId) => select(foodPortions)
    ..where((row) => row.foodId.equals(foodId))
    ..orderBy([(row) => OrderingTerm.asc(row.id)]);

  /// Cached foods whose names hold every one of [words].
  Selectable<FoodRow> search(List<String> words) => customSelect(
    'SELECT * FROM foods WHERE ${foodSearchWhere(words)}',
    variables: [
      for (final pattern in foodSearchPatterns(words)) Variable(pattern),
    ],
    readsFrom: {foods},
  ).asyncMap(foods.mapFromRow);

  /// Replaces the cached food with [food], its [nutrients], and its
  /// [portions].
  Future<void> replaceFood(
    FoodsCompanion food, {
    required List<FoodNutrientsCompanion> nutrients,
    required List<FoodPortionsCompanion> portions,
  }) => transaction(() async {
    final id = food.id.value;
    await deleteFood(id);
    await into(foods).insert(food);
    await batch((batch) {
      batch
        ..insertAll(foodNutrients, nutrients)
        ..insertAll(foodPortions, portions);
    });
  });

  /// Deletes the cached food [id] with its nutrients and portions.
  Future<void> deleteFood(String id) => transaction(() async {
    await (delete(foods)..where((row) => row.id.equals(id))).go();
    await (delete(foodNutrients)..where((row) => row.foodId.equals(id))).go();
    await (delete(foodPortions)..where((row) => row.foodId.equals(id))).go();
  });

  /// The matches of [recipeId]'s ingredient lines.
  Selectable<NutritionMatchRow> matchesOf(String recipeId) {
    final query =
        select(nutritionMatches).join([
            innerJoin(
              ingredientLines,
              ingredientLines.id.equalsExp(nutritionMatches.ingredientLineId),
              useColumns: false,
            ),
          ])
          ..where(ingredientLines.recipeId.equals(recipeId))
          ..orderBy([OrderingTerm.asc(nutritionMatches.id)]);
    return query.map((row) => row.readTable(nutritionMatches));
  }

  /// The match with [id].
  Selectable<NutritionMatchRow> match(String id) =>
      select(nutritionMatches)..where((row) => row.id.equals(id));

  /// The match of the line [ingredientLineId], if it has one.
  Selectable<NutritionMatchRow> matchOfLine(String ingredientLineId) =>
      select(nutritionMatches)
        ..where((row) => row.ingredientLineId.equals(ingredientLineId));

  /// Inserts or replaces a match.
  Future<void> upsertMatch(NutritionMatchesCompanion match) =>
      into(nutritionMatches).insertOnConflictUpdate(match);

  /// Deletes the match [id].
  Future<void> deleteMatch(String id) =>
      (delete(nutritionMatches)..where((row) => row.id.equals(id))).go();
}
