import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/editor/application/editor_draft.dart';
import 'package:sousvite/features/editor/presentation/draft_text_field.dart';
import 'package:sousvite/features/editor/presentation/recipe_photo_editor.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The recipe's photo, name, servings, and total time, with a note when
/// it was just imported.
class const RecipeDetailsEditor({
  /// The recipe being edited.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read once: the fields keep their own text after this.
    final recipe = ref.read(editorDraftProvider(recipeId)).value?.draft.recipe;
    if (recipe == null) return const SizedBox.shrink();
    final draft = ref.read(editorDraftProvider(recipeId).notifier);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: .stretch,
      spacing: AppSpacing.space4,
      children: [
        _ImportedNote(recipeId: recipeId),
        RecipePhotoEditor(recipeId: recipeId),
        DraftTextField(
          initialText: recipe.title,
          label: l10n.editor_name,
          style: context.textStyles.headlineSmall,
          onChanged: draft.setTitle,
        ),
        Row(
          spacing: AppSpacing.space4,
          children: [
            Expanded(
              child: DraftTextField(
                initialText: recipe.servings.format(),
                label: l10n.editor_servings,
                keyboardType: TextInputType.number,
                onChanged: (text) {
                  if (int.tryParse(text.trim()) case final servings?) {
                    draft.setServings(Quantity(servings));
                  }
                },
              ),
            ),
            Expanded(
              child: DraftTextField(
                initialText: recipe.totalTime?.inMinutes.toString() ?? '',
                label: l10n.editor_totalMinutes,
                keyboardType: TextInputType.number,
                onChanged: (text) {
                  final minutes = int.tryParse(text.trim());
                  draft.setTotalTime(
                    minutes == null || minutes <= 0
                        ? null
                        : Duration(minutes: minutes),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// "Imported from Serious Eats. Check the ingredients and steps, then
/// save." Shown until an imported recipe is saved.
class const _ImportedNote({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = ref.watch(
      editorDraftProvider(recipeId).select((state) {
        final value = state.value;
        if (value == null ||
            value.saved?.recipe.updatedAt != value.saved?.recipe.createdAt) {
          return null;
        }
        final recipe = value.draft.recipe;
        return recipe.sourceName ?? recipe.sourceUrl;
      }),
    );
    if (source == null) return const SizedBox.shrink();
    return Text(
      context.l10n.editor_importedFrom(source),
      style: context.textStyles.bodyMedium?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
    );
  }
}

/// The recipe's notes.
class const RecipeNotesEditor({
  /// The recipe being edited.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes =
        ref.read(editorDraftProvider(recipeId)).value?.draft.recipe.notes ?? '';
    return DraftTextField(
      initialText: notes,
      label: context.l10n.editor_notes,
      maxLines: null,
      onChanged: ref.read(editorDraftProvider(recipeId).notifier).setNotes,
    );
  }
}
