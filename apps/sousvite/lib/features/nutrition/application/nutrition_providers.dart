import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/app/services/nutrition_api.dart';
import 'package:sousvite/features/nutrition/application/food_choice.dart';
import 'package:sousvite/features/nutrition/application/nutrition_basis.dart';
import 'package:sousvite/features/nutrition/application/nutrition_math.dart';

part 'nutrition_providers.g.dart';

/// A recipe's ingredient lines, in order.
@riverpod
Stream<List<IngredientLine>> nutritionLines(Ref ref, RecipeId recipeId) =>
    ref.watch(recipeRepositoryProvider).watchIngredientLines(recipeId);

/// The recipe's ingredient line ids, in order. Emits only when lines are
/// added, removed, or moved, so the match list doesn't rebuild on edits.
@riverpod
Stream<List<IngredientLineId>> nutritionLineIds(Ref ref, RecipeId recipeId) =>
    ref
        .watch(recipeRepositoryProvider)
        .watchIngredientLines(recipeId)
        .map((lines) => [for (final line in lines) line.id])
        .distinct(listEquals);

/// Each matched line's match, by line id.
@riverpod
Stream<Map<IngredientLineId, NutritionMatch>> nutritionMatches(
  Ref ref,
  RecipeId recipeId,
) => ref
    .watch(foodRepositoryProvider)
    .watchMatches(recipeId)
    .map((matches) => {for (final m in matches) m.ingredientLineId: m})
    .distinct(mapEquals);

/// A food's name and source.
@riverpod
Future<Food?> nutritionFood(Ref ref, FoodId foodId) =>
    ref.watch(foodRepositoryProvider).getFood(foodId);

/// A food's nutrients per 100 g.
@riverpod
Future<List<FoodNutrient>> foodNutrients(Ref ref, FoodId foodId) =>
    ref.watch(foodRepositoryProvider).getNutrients(foodId);

/// A food's household portions, for working out a line's weight.
@riverpod
Future<List<FoodPortion>> foodPortions(Ref ref, FoodId foodId) =>
    ref.watch(foodRepositoryProvider).getPortions(foodId);

/// This user's settings for a recipe, or null if never changed.
@riverpod
Stream<UserRecipePrefs?> nutritionPrefs(Ref ref, RecipeId recipeId) =>
    ref.watch(userRecipePrefsRepositoryProvider).watchPrefs(recipeId);

/// How many servings the recipe makes as written.
@riverpod
Stream<Quantity?> recipeYield(Ref ref, RecipeId recipeId) => ref
    .watch(recipeRepositoryProvider)
    .watchRecipe(recipeId)
    .map((recipe) => recipe?.servings)
    .distinct();

/// The number of servings per-serving nutrition divides the batch into:
/// the user's remembered choice, else the recipe's own servings (PRD 7.4).
@riverpod
AsyncValue<Quantity> nutritionServings(Ref ref, RecipeId recipeId) {
  final prefs = ref.watch(nutritionPrefsProvider(recipeId));
  final recipeServings = ref.watch(recipeYieldProvider(recipeId));
  if (prefs case AsyncData(value: UserRecipePrefs(:final servings))) {
    return AsyncData(servings);
  }
  return switch ((prefs, recipeServings)) {
    (AsyncError(:final error, :final stackTrace), _) ||
    (
      _,
      AsyncError(:final error, :final stackTrace),
    ) => AsyncError(error, stackTrace),
    (AsyncData(), AsyncData(:final value)) => AsyncData(value ?? Quantity.one),
    _ => const AsyncLoading(),
  };
}

/// Nutrition for the whole batch, from every matched line.
///
/// Built synchronously from the matches and each food's nutrients, so a
/// change shows at once instead of passing through a loading state.
@riverpod
AsyncValue<NutrientAmounts> batchNutrition(Ref ref, RecipeId recipeId) {
  final matches = ref.watch(nutritionMatchesProvider(recipeId));
  if (matches case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  final byLine = matches.value;
  if (byLine == null) return const AsyncLoading();

  final nutrientsByFood = <FoodId, List<FoodNutrient>>{};
  for (final foodId in {for (final match in byLine.values) match.foodId}) {
    final nutrients = ref.watch(foodNutrientsProvider(foodId));
    if (nutrients case AsyncError(:final error, :final stackTrace)) {
      return AsyncError(error, stackTrace);
    }
    final value = nutrients.value;
    if (value == null) return const AsyncLoading();
    nutrientsByFood[foodId] = value;
  }
  return AsyncData(batchTotals(byLine.values, nutrientsByFood));
}

/// Nutrition on the basis the user picked: one serving or the batch.
@riverpod
AsyncValue<NutrientAmounts> displayedNutrition(Ref ref, RecipeId recipeId) {
  final batch = ref.watch(batchNutritionProvider(recipeId));
  if (ref.watch(nutritionBasisControllerProvider(recipeId)) == .batch) {
    return batch;
  }
  final servings = ref.watch(nutritionServingsProvider(recipeId));
  return switch ((batch, servings)) {
    (AsyncError(:final error, :final stackTrace), _) ||
    (
      _,
      AsyncError(:final error, :final stackTrace),
    ) => AsyncError(error, stackTrace),
    (AsyncData(value: final batch), AsyncData(value: final servings)) =>
      AsyncData(perServing(batch, servings)),
    _ => const AsyncLoading(),
  };
}

/// Lines with no match, in order. Their nutrition is missing from the
/// totals, so the screen flags them (PRD 7.4).
@riverpod
AsyncValue<List<IngredientLineId>> unmatchedLineIds(
  Ref ref,
  RecipeId recipeId,
) {
  final lines = ref.watch(nutritionLinesProvider(recipeId));
  final matches = ref.watch(nutritionMatchesProvider(recipeId));
  return switch ((lines, matches)) {
    (AsyncError(:final error, :final stackTrace), _) ||
    (
      _,
      AsyncError(:final error, :final stackTrace),
    ) => AsyncError(error, stackTrace),
    (AsyncData(value: final lines), AsyncData(value: final matches)) =>
      AsyncData([
        for (final line in lines)
          if (!matches.containsKey(line.id)) line.id,
      ]),
    _ => const AsyncLoading(),
  };
}

/// Foods matching [query] for changing a match: bundled and cached foods
/// first, since generic USDA data is the most accurate, then branded
/// products found online (PRD 7.4).
@riverpod
Future<List<FoodChoice>> foodSearch(Ref ref, String query) async {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return const [];
  final (saved, online) = await (
    ref.watch(foodRepositoryProvider).searchFoods(trimmed),
    ref.watch(nutritionApiProvider).search(trimmed),
  ).wait;
  final savedIds = {for (final food in saved) food.id};
  return [
    for (final food in saved) SavedFoodChoice(food),
    for (final food in online)
      if (!savedIds.contains(food.food.id)) OnlineFoodChoice(food),
  ];
}
