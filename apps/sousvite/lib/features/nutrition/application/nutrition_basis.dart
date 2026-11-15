import 'package:design_system/design_system.dart' show NutritionBasis;
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// The design system's toggle and this controller share one enum.
export 'package:design_system/design_system.dart' show NutritionBasis;

part 'nutrition_basis.g.dart';

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
