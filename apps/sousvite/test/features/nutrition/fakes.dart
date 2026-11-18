import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sousvite/app/services/nutrition_api.dart';

/// Emits [read]'s value on listen and after every [changes] event,
/// skipping repeats like a Drift watch query with `distinct()`.
Stream<T> watchValue<T>(
  Stream<void> changes,
  T Function() read, {
  bool Function(T, T)? equals,
}) {
  late final StreamController<T> controller;
  StreamSubscription<void>? subscription;
  controller = StreamController<T>(
    onListen: () {
      controller.add(read());
      subscription = changes.listen((_) => controller.add(read()));
    },
    // Not returning the cancel future: a broadcast subscription's is a
    // root-zone future, which fake-async widget tests never complete, so
    // `stream.first` would hang.
    onCancel: () {
      unawaited(subscription?.cancel());
    },
  );
  return controller.stream.distinct(equals);
}

/// An in-memory [FoodRepository] for one recipe: [watchMatches] returns
/// every match, whatever the recipe id.
class FakeFoodRepository() implements FoodRepository {
  final foods = <FoodId, Food>{};
  final nutrients = <FoodId, List<FoodNutrient>>{};
  final portions = <FoodId, List<FoodPortion>>{};
  final matches = <NutritionMatchId, NutritionMatch>{};
  final _changes = StreamController<void>.broadcast(sync: true);

  /// Foods [searchFoods] returns, whatever the query.
  List<Food> searchResults = const [];

  void addFood(
    Food food, {
    Map<String, double> per100g = const {},
    List<FoodPortion> portions = const [],
  }) {
    foods[food.id] = food;
    nutrients[food.id] = [
      for (final MapEntry(:key, :value) in per100g.entries)
        FoodNutrient(foodId: food.id, nutrientCode: key, amountPer100g: value),
    ];
    this.portions[food.id] = portions;
  }

  @override
  Future<Food?> getFood(FoodId id) async => foods[id];

  @override
  Future<List<FoodNutrient>> getNutrients(FoodId foodId) async =>
      nutrients[foodId] ?? const [];

  @override
  Future<List<FoodPortion>> getPortions(FoodId foodId) async =>
      portions[foodId] ?? const [];

  @override
  Future<List<Food>> searchFoods(String query, {int limit = 20}) async =>
      searchResults;

  @override
  Future<List<Food>> genericFoods() async => [
    for (final food in foods.values)
      if (food.source == NutritionSource.usda) food,
  ];

  @override
  Future<void> saveFood(
    Food food, {
    required List<FoodNutrient> nutrients,
    required List<FoodPortion> portions,
  }) async {
    foods[food.id] = food;
    this.nutrients[food.id] = nutrients;
    this.portions[food.id] = portions;
  }

  @override
  Stream<List<NutritionMatch>> watchMatches(RecipeId recipeId) => watchValue(
    _changes.stream,
    () => matches.values.toList(),
    equals: listEquals,
  );

  @override
  Future<void> saveMatch(NutritionMatch match) async {
    matches[match.id] = match;
    _changes.add(null);
  }

  @override
  Future<void> deleteMatch(NutritionMatchId id) async {
    matches.remove(id);
    _changes.add(null);
  }
}

/// An in-memory [UserRecipePrefsRepository].
class FakeUserRecipePrefsRepository() implements UserRecipePrefsRepository {
  final prefs = <RecipeId, UserRecipePrefs>{};
  final _changes = StreamController<void>.broadcast(sync: true);

  @override
  Stream<UserRecipePrefs?> watchPrefs(RecipeId recipeId) =>
      watchValue(_changes.stream, () => prefs[recipeId]);

  @override
  Future<void> savePrefs(UserRecipePrefs value) async {
    prefs[value.recipeId] = value;
    _changes.add(null);
  }
}

/// A [RecipeRepository] with recipes and lines in memory. Methods nutrition
/// doesn't use throw.
class FakeRecipeRepository() extends Fake implements RecipeRepository {
  final recipes = <RecipeId, Recipe>{};
  final lines = <IngredientLineId, IngredientLine>{};
  final _changes = StreamController<void>.broadcast(sync: true);

  @override
  Stream<List<RecipeId>> watchRecipeIds() => watchValue(
    _changes.stream,
    () => recipes.keys.toList(),
    equals: listEquals,
  );

  @override
  Stream<Recipe?> watchRecipe(RecipeId id) =>
      watchValue(_changes.stream, () => recipes[id]);

  @override
  Stream<List<IngredientLine>> watchIngredientLines(RecipeId recipeId) =>
      watchValue(
        _changes.stream,
        () =>
            lines.values.where((line) => line.recipeId == recipeId).toList()
              ..sort((a, b) => a.sortKey.compareTo(b.sortKey.value)),
        equals: listEquals,
      );

  @override
  Future<void> saveRecipe(Recipe recipe) async {
    recipes[recipe.id] = recipe;
    _changes.add(null);
  }

  @override
  Future<void> saveIngredientLine(IngredientLine line) async {
    lines[line.id] = line;
    _changes.add(null);
  }
}

/// A [NutritionApi] that returns [results] for every search.
class FakeNutritionApi(final List<OnlineFood> results) implements NutritionApi {
  @override
  Future<List<OnlineFood>> search(String query) async => results;

  @override
  Future<OnlineFood?> lookupBarcode(String barcode) async => null;
}

/// Test data builders.
abstract final class NutritionFixtures() {
  static const recipeId = RecipeId('oats');

  static Recipe recipe({int servings = 4}) => Recipe(
    id: recipeId,
    title: 'Oatmeal',
    servings: Quantity(servings),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  static IngredientLine line(String id, {Quantity? quantity, Unit? unit}) =>
      IngredientLine(
        id: IngredientLineId(id),
        recipeId: recipeId,
        rawText: id,
        sortKey: SortKey(id),
        name: id,
        quantity: quantity,
        unit: unit,
      );

  static Food food(
    String id, {
    NutritionSource source = NutritionSource.usda,
  }) => Food(id: FoodId(id), source: source, externalId: id, name: id);

  static NutritionMatch match(String lineId, String foodId, double grams) =>
      NutritionMatch(
        id: NutritionMatchId('m-$lineId'),
        ingredientLineId: IngredientLineId(lineId),
        foodId: FoodId(foodId),
        source: NutritionSource.usda,
        gramWeight: grams,
      );
}
