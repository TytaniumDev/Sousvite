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
/// Deleting keeps the recipes, goes back to the library, and offers Undo
/// instead of asking first (DESIGN_SYSTEM.md §10.8).
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
      final editor = ref.read(folderEditorProvider.notifier);
      final container = ProviderScope.containerOf(context, listen: false);
      final deleted = await editor.delete(folderId);
      if (deleted == null) return;
      router.go(LibraryRoutes.path);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.library_folderDeleted),
          action: SnackBarAction(
            label: l10n.library_undo,
            onPressed: () =>
                container.read(folderEditorProvider.notifier).restore(deleted),
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
