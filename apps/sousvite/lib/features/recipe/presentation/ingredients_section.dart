import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/recipe/application/recipe_data.dart';
import 'package:sousvite/features/recipe/application/recipe_outline.dart';
import 'package:sousvite/features/recipe/presentation/recipe_ingredient_row.dart';
import 'package:sousvite/features/recipe/presentation/recipe_servings.dart';
import 'package:sousvite/features/recipe/presentation/recipe_unit_picker.dart';
import 'package:sousvite/features/recipe/presentation/section_title.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// Ingredients with the servings stepper and unit choice, grouped by
/// section.
class const IngredientsSection({
  /// The recipe whose ingredients this shows.
  required final RecipeId recipeId,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .start,
    children: [
      SectionTitle(context.l10n.recipe_ingredients),
      const SizedBox(height: AppSpacing.space3),
      RecipeServings(recipeId: recipeId),
      const SizedBox(height: AppSpacing.space3),
      RecipeUnitPicker(recipeId: recipeId),
      const SizedBox(height: AppSpacing.space3),
      _IngredientList(recipeId: recipeId),
    ],
  );
}

/// Rebuilds only when lines are added, removed, moved, or regrouped.
class const _IngredientList({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(ingredientOutlineProvider(recipeId)),
    data: (outline) => Column(
      crossAxisAlignment: .stretch,
      children: [
        for (final group in outline.groups) ...[
          if (group.sectionId case final sectionId?)
            _IngredientSectionName(
              key: ValueKey(sectionId),
              recipeId: recipeId,
              sectionId: sectionId,
            ),
          for (final lineId in group.lineIds)
            RecipeIngredientRow(
              key: ValueKey(lineId),
              recipeId: recipeId,
              lineId: lineId,
            ),
        ],
      ],
    ),
  );
}

class const _IngredientSectionName({
  required final RecipeId recipeId,
  required final IngredientSectionId sectionId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.only(
      top: AppSpacing.space4,
      bottom: AppSpacing.space1,
    ),
    child: Semantics(
      header: true,
      child: Text(
        ref.watch(ingredientSectionNameProvider(recipeId, sectionId)) ?? '',
        style: context.textStyles.titleSmall,
      ),
    ),
  );
}
