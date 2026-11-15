import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/nutrition/nutrition.dart';
import 'package:sousvite/features/recipe/presentation/section_title.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Calories and macros, with a way to the full nutrition screen
/// (DESIGN_SYSTEM.md §10.1).
class const NutritionSection({
  /// The recipe whose nutrition this shows.
  required final RecipeId recipeId,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.space8),
    child: Column(
      crossAxisAlignment: .start,
      children: [
        SectionTitle(context.l10n.recipe_nutrition),
        const SizedBox(height: AppSpacing.space3),
        NutritionSummary(recipeId: recipeId),
        TextButton(
          onPressed: () => context.push(NutritionRoutes.location(recipeId)),
          child: Text(context.l10n.recipe_allNutrients),
        ),
      ],
    ),
  );
}
