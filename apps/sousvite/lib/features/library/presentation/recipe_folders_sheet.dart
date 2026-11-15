import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/library/application/folders.dart';
import 'package:sousvite/features/library/presentation/folder_name_dialog.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Shows a sheet where [recipeId] is put in or taken out of folders. A
/// recipe can be in several folders (PRD 7.1).
Future<void> showRecipeFoldersSheet(BuildContext context, RecipeId recipeId) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => RecipeFoldersSheet(recipeId: recipeId),
    );

/// The folders a recipe is in, as a checklist, plus "New folder".
class const RecipeFoldersSheet({
  /// The recipe being sorted into folders.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ids = ref.watch(folderIdsProvider) ?? const <FolderId>[];
    return SafeArea(
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space6),
            child: Text(
              l10n.library_foldersSheetTitle,
              style: context.textStyles.titleLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          if (ids.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space6,
                vertical: AppSpacing.space3,
              ),
              child: Text(
                l10n.library_noFolders,
                style: context.textStyles.bodyMedium,
              ),
            ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final id in ids)
                  _FolderCheckbox(
                    key: ValueKey(id),
                    folderId: id,
                    recipeId: recipeId,
                  ),
              ],
            ),
          ),
          _NewFolderTile(recipeId: recipeId),
          const SizedBox(height: AppSpacing.space2),
        ],
      ),
    );
  }
}

class const _FolderCheckbox({
  required final FolderId folderId,
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(folderNameProvider(folderId)) ?? '';
    final inFolder = ref.watch(isRecipeInFolderProvider(folderId, recipeId));
    return CheckboxListTile(
      title: Text(name),
      value: inFolder ?? false,
      onChanged: inFolder == null
          ? null
          : (checked) => ref
                .read(folderEditorProvider.notifier)
                .setRecipeInFolder(
                  folderId,
                  recipeId,
                  inFolder: checked ?? false,
                ),
    );
  }
}

/// Creates a folder and puts the recipe in it.
class const _NewFolderTile({required final RecipeId recipeId})
    extends ConsumerWidget {
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
      await ref
          .read(folderEditorProvider.notifier)
          .setRecipeInFolder(folderId, recipeId, inFolder: true);
    },
  );
}
