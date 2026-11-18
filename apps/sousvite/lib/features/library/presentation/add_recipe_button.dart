import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/editor/editor.dart';
import 'package:sousvite/features/import/import.dart';
import 'package:sousvite/features/library/application/folders.dart';
import 'package:sousvite/features/library/presentation/folder_name_dialog.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Adds a recipe to [folderId]: import it from a link, or write it in the
/// editor. Every recipe belongs in a folder, so with no [folderId] (the
/// library's main page) it first asks which folder.
class const AddRecipeButton({
  /// The folder the new recipe goes into, or null to ask.
  required final FolderId? folderId,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    onPressed: () async {
      final folderId =
          this.folderId ??
          await showModalBottomSheet<FolderId>(
            context: context,
            showDragHandle: true,
            isScrollControlled: true,
            builder: (_) => const _PickFolderSheet(),
          );
      if (folderId == null || !context.mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => _AddRecipeSheet(folderId: folderId),
      );
    },
    icon: const Icon(Symbols.add_rounded),
    label: Text(context.l10n.library_addRecipe),
  );
}

/// Every folder, plus "New folder". Pops the chosen folder's id.
class const _PickFolderSheet() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(folderIdsProvider) ?? const <FolderId>[];
    return SafeArea(
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space6),
            child: Text(
              context.l10n.library_pickFolderTitle,
              style: context.textStyles.titleLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final id in ids)
                  _FolderOption(key: ValueKey(id), folderId: id),
              ],
            ),
          ),
          const _NewFolderOption(),
          const SizedBox(height: AppSpacing.space2),
        ],
      ),
    );
  }
}

class const _FolderOption({required final FolderId folderId, super.key})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    leading: const Icon(Symbols.folder_rounded),
    title: Text(ref.watch(folderNameProvider(folderId)) ?? ''),
    onTap: () => Navigator.pop(context, folderId),
  );
}

/// Makes a folder and picks it.
class const _NewFolderOption() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    leading: const Icon(Symbols.create_new_folder_rounded),
    title: Text(context.l10n.library_newFolder),
    onTap: () async {
      final name = await showFolderNameDialog(
        context,
        title: context.l10n.library_newFolder,
        confirmLabel: context.l10n.library_createFolder,
      );
      if (name == null) return;
      final folderId = await ref
          .read(folderEditorProvider.notifier)
          .create(name);
      if (context.mounted) Navigator.pop(context, folderId);
    },
  );
}

/// Import from a link, or write a recipe, into [folderId].
class const _AddRecipeSheet({required final FolderId folderId})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void open(String location) {
      final router = GoRouter.of(context);
      Navigator.pop(context);
      unawaited(router.push(location));
    }

    return SafeArea(
      child: Column(
        mainAxisSize: .min,
        children: [
          ListTile(
            leading: const Icon(Symbols.link_rounded),
            title: Text(l10n.library_importRecipe),
            onTap: () => open(ImportRoutes.location(folderId: folderId)),
          ),
          ListTile(
            leading: const Icon(Symbols.edit_note_rounded),
            title: Text(l10n.library_writeRecipe),
            onTap: () =>
                open(EditorRoutes.newRecipeLocation(folderId: folderId)),
          ),
        ],
      ),
    );
  }
}
