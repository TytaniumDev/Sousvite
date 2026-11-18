import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/library/application/folders.dart';
import 'package:sousvite/features/library/library_routes.dart';
import 'package:sousvite/features/library/presentation/folder_name_dialog.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Rename or delete a folder, from its page's app bar.
///
/// Deleting goes back to the library and offers Undo (DESIGN_SYSTEM.md
/// §10.8). Recipes in no other folder are deleted with the folder, since
/// every recipe belongs in a folder, so then it asks first and says how
/// many (§10.11).
class const FolderMenu({
  /// The folder this menu changes.
  required final FolderId folderId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    Future<void> rename() async {
      final name = await showFolderNameDialog(
        context,
        title: l10n.library_renameFolder,
        confirmLabel: MaterialLocalizations.of(context).saveButtonLabel,
        initialName: ref.read(folderNameProvider(folderId)) ?? '',
      );
      if (name == null) return;
      await ref.read(folderEditorProvider.notifier).rename(folderId, name);
    }

    Future<void> delete() async {
      // Read everything first: leaving the page disposes this menu's ref.
      final messenger = ScaffoldMessenger.of(context);
      final router = GoRouter.of(context);
      final container = ProviderScope.containerOf(context, listen: false);
      // Nothing watches the editor, so it may be disposed between calls:
      // read it afresh for each one.
      FolderEditor editor() => container.read(folderEditorProvider.notifier);
      final name = ref.read(folderNameProvider(folderId)) ?? '';
      final onlyHere = (await editor().recipesOnlyIn(folderId)).length;
      // Deleting recipes too is worth a confirm, though Undo still works.
      if (onlyHere > 0) {
        if (!context.mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) =>
              _ConfirmDelete(folderName: name, recipeCount: onlyHere),
        );
        if (confirmed != true) return;
      }
      final deleted = await editor().delete(folderId);
      if (deleted == null) return;
      router.go(LibraryRoutes.path);
      final recipeCount = deleted.recipes.length;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            recipeCount == 0
                ? l10n.library_folderDeleted
                : l10n.library_folderAndRecipesDeleted(recipeCount),
          ),
          action: SnackBarAction(
            label: l10n.library_undo,
            onPressed: () => editor().restore(deleted),
          ),
        ),
      );
    }

    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Symbols.edit_rounded),
          onPressed: rename,
          child: Text(l10n.library_renameFolder),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Symbols.delete_rounded),
          onPressed: delete,
          child: Text(l10n.library_deleteFolder),
        ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: l10n.library_folderOptions,
        icon: const Icon(Symbols.more_vert_rounded),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

/// Asks before deleting a folder whose recipes are in no other folder,
/// saying how many will go with it. Pops true to delete.
class const _ConfirmDelete({
  required final String folderName,
  required final int recipeCount,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.library_deleteFolderTitle(folderName)),
      content: Text(l10n.library_deleteFolderMessage(recipeCount)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.library_deleteConfirm),
        ),
      ],
    );
  }
}
