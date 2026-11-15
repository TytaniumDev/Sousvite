import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/library/presentation/recipe_folders_sheet.dart';
import 'package:sousvite/features/recipe/recipe.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/format/duration_label.dart';

/// One recipe in the library. Watches only the recipe's name and total
/// time, so other edits to the recipe don't rebuild it.
///
/// Tap opens the recipe. Press and hold puts it in folders.
class const LibraryRecipeCard({
  /// The recipe this card shows.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(
      recipeProvider(recipeId).select(
        (recipe) => recipe.value == null
            ? null
            : (title: recipe.value!.title, totalTime: recipe.value!.totalTime),
      ),
    );
    if (card == null) return const SizedBox.shrink();
    final totalTime = card.totalTime;
    // Calories and photos join the card once nutrition (APP-NUT) and
    // photos (MEDIA-1) are built.
    return Semantics(
      onLongPressHint: context.l10n.library_editFoldersHint,
      child: GestureDetector(
        onLongPress: () => showRecipeFoldersSheet(context, recipeId),
        child: RecipeCard(
          title: card.title,
          totalTimeLabel: totalTime == null
              ? null
              : context.l10n.durationLabel(totalTime),
          onTap: () => context.push(RecipeRoutes.location(recipeId)),
        ),
      ),
    );
  }
}
