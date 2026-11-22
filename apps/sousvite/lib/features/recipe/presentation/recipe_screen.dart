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

/// The recipe page: photo, name, actions, ingredients, nutrition, steps,
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
    return PageScaffold(
      actions: [if (exists.value ?? false) RecipeMenu(recipeId: recipeId)],
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

/// One column on phones. With room for two panes, the photo, name,
/// actions, ingredients, and nutrition sit in a side pane beside the steps
/// and notes, and each scrolls on its own (DESIGN_SYSTEM.md §10.1).
class const _RecipeBody({required final RecipeId recipeId})
    extends StatelessWidget {
  static const _bottom = EdgeInsets.only(bottom: AppSpacing.space12);

  @override
  Widget build(BuildContext context) => PaneLayout(
    sideAt: .start,
    side: (context, insets) => FadingEdges(
      child: ListView(
        padding: insets + _bottom,
        children: [_RecipeOverview(recipeId: recipeId)],
      ),
    ),
    main: (context, insets) => FadingEdges(
      child: ListView(
        // Lines the first section up with the name when there's no photo.
        padding:
            insets + _bottom + const EdgeInsets.only(top: AppSpacing.space4),
        children: [_RecipeDetails(recipeId: recipeId)],
      ),
    ),
    onePane: (context, insets) => FadingEdges(
      child: ListView(
        padding: insets + _bottom,
        children: [
          _RecipeOverview(recipeId: recipeId),
          const SizedBox(height: AppSpacing.space8),
          _RecipeDetails(recipeId: recipeId),
        ],
      ),
    ),
  );
}

/// The photo, name, actions, ingredients, and nutrition: what you need to
/// decide on a recipe and get ready.
class const _RecipeOverview({required final RecipeId recipeId})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .stretch,
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
            IngredientsSection(recipeId: recipeId),
            NutritionSection(recipeId: recipeId),
          ],
        ),
      ),
    ],
  );
}

/// The steps and notes.
class const _RecipeDetails({required final RecipeId recipeId})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
    child: Column(
      crossAxisAlignment: .stretch,
      children: [
        StepsSection(recipeId: recipeId),
        RecipeNotes(recipeId: recipeId),
      ],
    ),
  );
}
