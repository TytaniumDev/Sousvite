import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/recipe/application/recipe_data.dart';

part 'recipe_units.g.dart';

/// This user's settings for one recipe, or null until they change one.
@riverpod
Stream<UserRecipePrefs?> recipePrefs(Ref ref, RecipeId recipeId) =>
    ref.watch(userRecipePrefsRepositoryProvider).watchPrefs(recipeId);

/// Which units this recipe's amounts are shown in: as written, US, or
/// metric (PRD 7.6). Remembered per recipe in `UserRecipePrefs`, so each
/// member of a joint share keeps their own choice.
@riverpod
class RecipeUnitSystem() extends _$RecipeUnitSystem {
  @override
  UnitSystem build(RecipeId recipeId) => ref.watch(
    recipePrefsProvider(recipeId)
        .select((prefs) => prefs.value?.unitSystem ?? UnitSystem.original),
  );

  /// Shows amounts in [system] and remembers it. Does nothing until the
  /// recipe has loaded, because new prefs start from its servings.
  Future<void> select(UnitSystem system) async {
    final current = ref.read(recipePrefsProvider(recipeId)).value;
    final servings =
        current?.servings ?? ref.read(recipeProvider(recipeId)).value?.servings;
    if (servings == null) return;
    final prefs =
        current ?? UserRecipePrefs(recipeId: recipeId, servings: servings);
    await ref
        .read(userRecipePrefsRepositoryProvider)
        .savePrefs(prefs.copyWith(unitSystem: system));
  }
}
