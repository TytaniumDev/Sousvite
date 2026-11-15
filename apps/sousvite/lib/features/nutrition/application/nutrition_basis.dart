import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nutrition_basis.g.dart';

/// Whether nutrition is shown for one serving or the whole batch.
enum NutritionBasis() {
  perServing,
  batch,
}

/// The basis the user picked for [recipeId]'s nutrition. Starts per
/// serving, the number most people want (PRD 7.4).
@riverpod
class NutritionBasisController() extends _$NutritionBasisController {
  @override
  NutritionBasis build(RecipeId recipeId) => .perServing;

  // A setter would read oddly at call sites: `notifier.select(basis)`.
  // ignore: use_setters_to_change_properties
  void select(NutritionBasis basis) => state = basis;
}
