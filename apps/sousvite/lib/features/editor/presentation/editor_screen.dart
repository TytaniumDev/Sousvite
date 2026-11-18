import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/editor/application/editor_draft.dart';
import 'package:sousvite/features/editor/presentation/editor_menu.dart';
import 'package:sousvite/features/editor/presentation/ingredients_editor.dart';
import 'package:sousvite/features/editor/presentation/recipe_details_editor.dart';
import 'package:sousvite/features/editor/presentation/steps_editor.dart';
import 'package:sousvite/features/library/library.dart';
import 'package:sousvite/features/recipe/recipe.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// Creates or edits a recipe (PRD 7.3, DESIGN_SYSTEM.md §10.2). Changes
/// stay in a draft until Save; leaving with changes asks first.
///
/// Also the review screen after an import: the imported recipe opens
/// here with an "Imported from …" note.
class const EditorScreen({
  /// The recipe to edit. An id that isn't saved yet starts a new recipe.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(
      editorDraftProvider(recipeId).select((state) => state.whenData((_) {})),
    );
    final l10n = context.l10n;
    return _DiscardGuard(
      recipeId: recipeId,
      child: Scaffold(
        appBar: AppBar(
          title: _EditorTitle(recipeId: recipeId),
          actions: [
            _SaveButton(recipeId: recipeId),
            EditorMenu(recipeId: recipeId),
          ],
        ),
        body: AsyncValueView(
          value: loaded,
          data: (_) => ReadingColumn(
            builder: (context, insets) => ListView(
              padding:
                  insets +
                  const EdgeInsets.fromLTRB(
                    AppSpacing.space4,
                    AppSpacing.space2,
                    AppSpacing.space4,
                    AppSpacing.space16,
                  ),
              children: [
                RecipeDetailsEditor(recipeId: recipeId),
                const SizedBox(height: AppSpacing.space8),
                _Heading(l10n.editor_ingredients),
                IngredientsEditor(recipeId: recipeId),
                const SizedBox(height: AppSpacing.space8),
                _Heading(l10n.editor_steps),
                StepsEditor(recipeId: recipeId),
                const SizedBox(height: AppSpacing.space8),
                RecipeNotesEditor(recipeId: recipeId),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class const _Heading(final String text) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.space2),
    child: Semantics(
      header: true,
      child: Text(text, style: context.textStyles.titleLarge),
    ),
  );
}

class const _EditorTitle({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Text(
    ref.watch(editorIsNewProvider(recipeId))
        ? context.l10n.editor_newTitle
        : context.l10n.editor_title,
  );
}

/// Saves the draft and goes to the recipe.
class const _SaveButton({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => TextButton(
    onPressed: () async {
      final messenger = ScaffoldMessenger.of(context);
      final saved = await ref
          .read(editorDraftProvider(recipeId).notifier)
          .save();
      if (!context.mounted) return;
      if (!saved) {
        messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.editor_nameRequired)),
        );
        return;
      }
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RecipeRoutes.location(recipeId));
      }
    },
    child: Text(context.l10n.editor_save),
  );
}

/// Asks before leaving with unsaved changes.
class const _DiscardGuard({
  required final RecipeId recipeId,
  required final Widget child,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => PopScope(
    canPop: !ref.watch(editorHasChangesProvider(recipeId)),
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop) return;
      final l10n = context.l10n;
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.editor_discardTitle),
          content: Text(l10n.editor_discardMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.editor_keepEditing),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.editor_discard),
            ),
          ],
        ),
      );
      if (!(discard ?? false) || !context.mounted) return;
      // pop, not maybePop: maybePop would ask again. The draft is dropped
      // with the screen.
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(LibraryRoutes.path);
      }
    },
    child: child,
  );
}
