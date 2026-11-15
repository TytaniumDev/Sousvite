import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/features/recipe/application/recipe_data.dart';
import 'package:sousvite/features/recipe/application/recipe_units.dart';

part 'recipe_scale.g.dart';

/// How much this recipe is scaled for cooking: 2 is a double batch
/// (PRD 7.6). Shared by the recipe page and cooking mode, so amounts in the
/// steps follow the scaling chosen on the page.
///
/// This is not the serving size that per-serving nutrition divides by;
/// that is remembered in `UserRecipePrefs` (PRD 7.4). The scale lasts while
/// the app runs.
@Riverpod(keepAlive: true)
class RecipeScale() extends _$RecipeScale {
  @override
  Quantity build(RecipeId recipeId) => Quantity.one;

  /// Scales by a multiplier, such as 2 for a double batch. Ignores zero
  /// and negative values.
  void scaleBy(Quantity factor) {
    if (factor > Quantity.zero) state = factor;
  }

  /// Scales a recipe written for [from] servings so the batch makes
  /// [servings]. Does nothing when [from] is not positive.
  ///
  /// The caller passes the recipe's servings, which it already shows,
  /// because a keep-alive provider can't watch the recipe.
  void scaleToServings(Quantity servings, {required Quantity from}) {
    if (from <= Quantity.zero) return;
    scaleBy(servingsMultiplier(from: from, to: servings));
  }

  /// Back to the recipe as written.
  void reset() => state = Quantity.one;
}

/// How many servings the batch makes at the current scale. Null until the
/// recipe loads.
@riverpod
Quantity? scaledServings(Ref ref, RecipeId recipeId) {
  final base = ref.watch(
    recipeProvider(recipeId).select((recipe) => recipe.value?.servings),
  );
  if (base == null) return null;
  return base * ref.watch(recipeScaleProvider(recipeId));
}

/// One ingredient line's amount as shown: `amount`, and for a range such
/// as "2–3 cups" the top of the range, `upTo`.
typedef LineAmount = ({Amount amount, Amount? upTo});

/// One line's amount at the current scale, in this recipe's unit system
/// (PRD 7.6). Null while loading, once the line is gone, or when the line
/// has no amount ("salt to taste").
///
/// As written, amounts are shown exactly as the recipe has them. Once
/// scaled or converted, they are rounded to something people can measure.
@riverpod
LineAmount? lineAmount(Ref ref, RecipeId recipeId, IngredientLineId lineId) {
  final written = ref.watch(
    ingredientLineProvider(recipeId, lineId).select(
      (line) => line?.quantity == null
          ? null
          : (
              amount: Amount(line!.quantity!, line.unit),
              upTo: line.quantityMax == null
                  ? null
                  : Amount(line.quantityMax!, line.unit),
            ),
    ),
  );
  if (written == null) return null;
  final factor = ref.watch(recipeScaleProvider(recipeId));
  final system = ref.watch(recipeUnitSystemProvider(recipeId));
  if (factor == Quantity.one && system == .original) return written;

  Amount shown(Amount amount) => amount.scaled(factor).measurableIn(system);
  final upTo = written.upTo;
  return (
    amount: shown(written.amount),
    upTo: upTo == null ? null : shown(upTo),
  );
}
