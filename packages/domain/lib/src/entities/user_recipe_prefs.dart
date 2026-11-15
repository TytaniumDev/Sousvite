import 'package:domain/src/value_objects/ids.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:units/units.dart';

part 'user_recipe_prefs.freezed.dart';

/// This user's settings for one recipe. Kept apart from [RecipeId]'s own
/// fields so a joint share never overwrites another member's choices
/// (PRD 7.10).
@freezed
abstract class UserRecipePrefs with _$UserRecipePrefs {
  const factory({
    required RecipeId recipeId,

    /// The serving size per-serving nutrition uses (PRD 7.4).
    required Quantity servings,
    @Default(UnitSystem.original) UnitSystem unitSystem,
  }) = _UserRecipePrefs;
}
