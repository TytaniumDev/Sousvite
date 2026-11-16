import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/editor/application/editor_draft.dart';
import 'package:sousvite/features/editor/application/recipe_copies.dart';
import 'package:sousvite/features/editor/editor_routes.dart';
import 'package:sousvite/features/library/library.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Duplicate or delete a saved recipe. Hidden for a new one.
///
/// Deleting offers Undo instead of asking first (DESIGN_SYSTEM.md §10.8).
class const EditorMenu({
  /// The recipe being edited.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(
      editorDraftProvider(recipeId).select((state) => state.value?.saved),
    );
    if (saved == null) return const SizedBox.shrink();
    final l10n = context.l10n;

    Future<void> duplicate() async {
      final copyId = await ref
          .read(recipeCopiesProvider)
          .duplicate(saved, title: l10n.editor_copyTitle(saved.recipe.title));
      if (context.mounted) {
        context.pushReplacement(EditorRoutes.location(copyId));
      }
    }

    Future<void> delete() async {
      final messenger = ScaffoldMessenger.of(context);
      final copies = ref.read(recipeCopiesProvider);
      await copies.delete(recipeId);
      if (context.mounted) context.go(LibraryRoutes.path);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.editor_deleted),
          action: SnackBarAction(
            label: l10n.editor_undo,
            onPressed: () => copies.restore(saved),
          ),
        ),
      );
    }

    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Symbols.content_copy_rounded),
          onPressed: duplicate,
          child: Text(l10n.editor_duplicate),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Symbols.delete_rounded),
          onPressed: delete,
          child: Text(l10n.editor_delete),
        ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: l10n.editor_moreOptions,
        icon: const Icon(Symbols.more_vert_rounded),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
