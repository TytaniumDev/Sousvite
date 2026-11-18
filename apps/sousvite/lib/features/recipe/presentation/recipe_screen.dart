import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/recipe/application/recipe_data.dart';
import 'package:sousvite/features/recipe/presentation/ingredients_section.dart';
import 'package:sousvite/features/recipe/presentation/nutrition_section.dart';
import 'package:sousvite/features/recipe/presentation/recipe_actions.dart';
import 'package:sousvite/features/recipe/presentation/recipe_header.dart';
import 'package:sousvite/features/recipe/presentation/recipe_menu.dart';
import 'package:sousvite/features/recipe/presentation/recipe_notes.dart';
import 'package:sousvite/features/recipe/presentation/recipe_photo.dart';
import 'package:sousvite/features/recipe/presentation/steps_section.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// The recipe page: photo, name, actions, ingredients, steps, nutrition,
/// and notes (DESIGN_SYSTEM.md §10.1).
///
/// This widget only watches whether the recipe exists; each part below
/// watches its own data.
class const RecipeScreen({
  /// The recipe to show.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exists = ref.watch(
      recipeProvider(recipeId)
          .select((recipe) => recipe.whenData((recipe) => recipe != null)),
    );
    return Scaffold(
      appBar: AppBar(
        actions: [if (exists.value ?? false) RecipeMenu(recipeId: recipeId)],
      ),
      body: AsyncValueView(
        value: exists,
        data: (exists) => exists
            ? _RecipeBody(recipeId: recipeId)
            : EmptyState(
                icon: Symbols.search_off_rounded,
                title: context.l10n.recipe_notFoundTitle,
                message: context.l10n.recipe_notFoundMessage,
              ),
      ),
    );
  }
}

class const _RecipeBody({required final RecipeId recipeId})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sideBySide = WindowSizeClass.of(context) == .expanded;
    return ReadingColumn(
      // Ingredients and steps side by side need more room than one column.
      maxWidth: sideBySide
          ? ReadingColumn.twoPaneWidth
          : ReadingColumn.readingWidth,
      builder: (context, insets) => ListView(
        padding: insets + const EdgeInsets.only(bottom: AppSpacing.space12),
        children: [
          // Full width on phones, so it sits outside the page's side padding.
          RecipePhoto(recipeId: recipeId),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space4,
              AppSpacing.space4,
              AppSpacing.space4,
              0,
            ),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                RecipeHeader(recipeId: recipeId),
                const SizedBox(height: AppSpacing.space4),
                RecipeActions(recipeId: recipeId),
                const SizedBox(height: AppSpacing.space8),
                if (sideBySide)
                  Row(
                    crossAxisAlignment: .start,
                    children: [
                      Expanded(child: IngredientsSection(recipeId: recipeId)),
                      const SizedBox(width: AppSpacing.space8),
                      Expanded(child: StepsSection(recipeId: recipeId)),
                    ],
                  )
                else ...[
                  IngredientsSection(recipeId: recipeId),
                  const SizedBox(height: AppSpacing.space8),
                  StepsSection(recipeId: recipeId),
                ],
                NutritionSection(recipeId: recipeId),
                RecipeNotes(recipeId: recipeId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
