import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/library/presentation/recipe_folders_sheet.dart';
import 'package:sousvite/features/recipe/recipe.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/format/duration_label.dart';
import 'package:sousvite/shared/photos/photos.dart';

/// One recipe in the library. Watches only the recipe's name, total
/// time, and photo, so other edits to the recipe don't rebuild it.
///
/// Tap opens the recipe. Press and hold puts it in folders.
class const LibraryRecipeCard({
  /// The recipe this card shows.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  /// Decodes photos only as wide as a card needs, in pixels, so a grid of
  /// full-size photos doesn't fill memory.
  static const int _photoCacheWidth = 800;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(
      recipeProvider(recipeId).select(
        (recipe) => recipe.value == null
            ? null
            : (
                title: recipe.value!.title,
                totalTime: recipe.value!.totalTime,
                photoRef: recipe.value!.photoRef,
              ),
      ),
    );
    if (card == null) return const SizedBox.shrink();
    final totalTime = card.totalTime;
    final photoRef = card.photoRef;
    // Calories join the card once nutrition (APP-NUT) is built.
    return Semantics(
      onLongPressHint: context.l10n.library_editFoldersHint,
      child: GestureDetector(
        onLongPress: () => showRecipeFoldersSheet(context, recipeId),
        child: RecipeCard(
          title: card.title,
          image: photoRef == null
              ? null
              : ResizeImage.resizeIfNeeded(
                  _photoCacheWidth,
                  null,
                  ref.watch(recipePhotosProvider).imageFor(photoRef),
                ),
          totalTimeLabel: totalTime == null
              ? null
              : context.l10n.durationLabel(totalTime),
          onTap: () => context.push(RecipeRoutes.location(recipeId)),
        ),
      ),
    );
  }
}
