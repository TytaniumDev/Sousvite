import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'checked_ingredients.g.dart';

/// The ingredient lines checked off while cooking [recipeId]. Kept while
/// the app runs, like the cook's place.
@Riverpod(keepAlive: true)
class CheckedIngredients() extends _$CheckedIngredients {
  @override
  Set<IngredientLineId> build(RecipeId recipeId) => const {};

  /// Checks [lineId] off, or back on.
  void setChecked(IngredientLineId lineId, {required bool checked}) => state = {
    for (final id in state)
      if (id != lineId) id,
    if (checked) lineId,
  };

  /// Unchecks everything, after finishing.
  void clear() => state = const {};
}

/// Whether [lineId] is checked off. Only that line's row rebuilds when it
/// changes.
@riverpod
bool isIngredientChecked(Ref ref, RecipeId recipeId, IngredientLineId lineId) =>
    ref.watch(
      checkedIngredientsProvider(recipeId)
          .select((ids) => ids.contains(lineId)),
    );
