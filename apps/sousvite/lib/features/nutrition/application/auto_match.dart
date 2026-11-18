import 'package:domain/domain.dart';
import 'package:nutrition/nutrition.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/nutrition/application/nutrition_math.dart';
import 'package:uuid/uuid.dart';

part 'auto_match.g.dart';

/// How many ingredient lines automatic matching matched, and how many it
/// left for the user because no food fit clearly.
typedef AutoMatchResult = ({int matched, int unmatched});

/// Matches unmatched ingredient lines to bundled USDA foods (ENGINEERING.md
/// §11.2), for "Fix all" and for recipes as they're imported.
///
/// A line is matched only when [matcher] finds a food that clearly fits
/// ([FoodMatched.isClear]) and its weight can be worked out from the line's
/// amount. Everything else stays unmatched, so it's flagged instead of
/// guessed (PRD 7.4). Lines that already have a match are never changed.
class AutoMatch({
  required final FoodRepository foods,
  required final RecipeRepository recipes,

  /// Picks the food for an ingredient name.
  required final FoodMatcher matcher,

  /// Makes a new unique id.
  required final String Function() newId,
}) {
  /// Matches [recipeId]'s unmatched lines.
  Future<AutoMatchResult> matchRecipe(RecipeId recipeId) async {
    final lines = await recipes.watchIngredientLines(recipeId).first;
    final matchedIds = {
      for (final match in await foods.watchMatches(recipeId).first)
        match.ingredientLineId,
    };
    var matched = 0;
    var unmatched = 0;
    for (final line in lines) {
      if (matchedIds.contains(line.id)) continue;
      if (await _matchLine(line)) {
        matched++;
      } else {
        unmatched++;
      }
    }
    return (matched: matched, unmatched: unmatched);
  }

  /// Matches the unmatched lines of every recipe in the library.
  Future<AutoMatchResult> matchLibrary() async {
    var matched = 0;
    var unmatched = 0;
    for (final recipeId in await recipes.watchRecipeIds().first) {
      final result = await matchRecipe(recipeId);
      matched += result.matched;
      unmatched += result.unmatched;
    }
    return (matched: matched, unmatched: unmatched);
  }

  /// Saves a match for [line], or returns false when no food fits clearly
  /// or its weight can't be worked out.
  Future<bool> _matchLine(IngredientLine line) async {
    final name = line.name;
    if (name == null || name.trim().isEmpty) return false;
    if (matcher.match(name) case FoodMatched(:final food, isClear: true)) {
      final grams = estimateGrams(
        line,
        await foods.getPortions(food.id),
        foodName: food.name,
      );
      if (grams == null || grams <= 0) return false;
      await foods.saveMatch(
        NutritionMatch(
          id: NutritionMatchId(newId()),
          ingredientLineId: line.id,
          foodId: food.id,
          source: food.source,
          gramWeight: grams,
        ),
      );
      return true;
    }
    return false;
  }
}

/// Picks foods for ingredient names from every bundled generic food.
///
/// Kept alive because indexing the foods takes a moment and they never
/// change; it's rebuilt once the bundled file has loaded.
@Riverpod(keepAlive: true)
Future<FoodMatcher> foodMatcher(Ref ref) async =>
    FoodMatcher(await ref.watch(foodRepositoryProvider).genericFoods());

/// Automatic matching with the app's repositories and [foodMatcher].
@Riverpod(keepAlive: true)
Future<AutoMatch> autoMatch(Ref ref) async => AutoMatch(
  foods: ref.watch(foodRepositoryProvider),
  recipes: ref.watch(recipeRepositoryProvider),
  matcher: await ref.watch(foodMatcherProvider.future),
  newId: const Uuid().v4,
);
