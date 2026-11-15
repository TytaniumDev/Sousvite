import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/nutrition/application/food_choice.dart';
import 'package:sousvite/features/nutrition/application/nutrition_math.dart';
import 'package:uuid/uuid.dart';

part 'nutrition_actions.g.dart';

/// Changes to a recipe's nutrition: matches and serving size. Screens call
/// these from callbacks with `ref.read(nutritionActionsProvider)`.
class NutritionActions({
  required final FoodRepository foods,
  required final UserRecipePrefsRepository prefs,

  /// Makes a new unique id.
  required final String Function() newId,
}) {
  /// How much [line] weighs as [choice], from the food's household
  /// portions, or null when its amount can't be converted.
  Future<double?> estimateWeight(
    IngredientLine line,
    FoodChoice choice,
  ) async => estimateGrams(line, switch (choice) {
    OnlineFoodChoice(:final online) => online.portions,
    SavedFoodChoice(:final food) => await foods.getPortions(food.id),
  });

  /// Matches [line] to the food in [choice], weighing [gramWeight] grams.
  /// Replaces the line's [current] match, if any. A food found online is
  /// cached first, so the recipe keeps working offline.
  Future<void> chooseFood(
    IngredientLine line,
    FoodChoice choice, {
    required double gramWeight,
    NutritionMatch? current,
  }) async {
    if (choice case OnlineFoodChoice(:final online)) {
      await foods.saveFood(
        online.food,
        nutrients: online.nutrients,
        portions: online.portions,
      );
    }
    await foods.saveMatch(
      NutritionMatch(
        id: current?.id ?? NutritionMatchId(newId()),
        ingredientLineId: line.id,
        foodId: choice.food.id,
        source: choice.food.source,
        gramWeight: gramWeight,
        userConfirmed: true,
      ),
    );
  }

  /// Corrects how much a matched line weighs.
  Future<void> setGramWeight(NutritionMatch match, double gramWeight) => foods
      .saveMatch(match.copyWith(gramWeight: gramWeight, userConfirmed: true));

  /// Leaves a line unmatched, so it is flagged instead of guessed.
  Future<void> removeMatch(NutritionMatch match) => foods.deleteMatch(match.id);

  /// Remembers how many servings [recipeId]'s nutrition divides into.
  Future<void> setServings(
    RecipeId recipeId,
    Quantity servings, {
    UserRecipePrefs? current,
  }) => prefs.savePrefs(
    current?.copyWith(servings: servings) ??
        UserRecipePrefs(recipeId: recipeId, servings: servings),
  );
}

@riverpod
NutritionActions nutritionActions(Ref ref) => NutritionActions(
  foods: ref.watch(foodRepositoryProvider),
  prefs: ref.watch(userRecipePrefsRepositoryProvider),
  newId: const Uuid().v4,
);
