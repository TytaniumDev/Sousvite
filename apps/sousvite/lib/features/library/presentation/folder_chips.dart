import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/library/application/folders.dart';
import 'package:sousvite/features/library/application/library_filter.dart';
import 'package:sousvite/features/library/presentation/folder_name_dialog.dart';
import 'package:sousvite/l10n/l10n.dart';

/// A row of chips: all recipes, each folder, and "New folder".
///
/// The row rebuilds when folders are added, removed, or reordered. Each
/// chip watches its own name and whether it is selected.
class const FolderChips({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(folderIdsProvider) ?? const <FolderId>[];
    return SingleChildScrollView(
      scrollDirection: .horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Row(
        spacing: AppSpacing.space2,
        children: [
          const _FolderChip(folderId: null),
          for (final id in ids) _FolderChip(key: ValueKey(id), folderId: id),
          const _NewFolderChip(),
        ],
      ),
    );
  }
}

/// One folder, or all recipes when [folderId] is null.
class const _FolderChip({required final FolderId? folderId, super.key})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = folderId;
    final selected = ref.watch(
      libraryFolderProvider.select((selected) => selected == id),
    );
    final label = id == null
        ? context.l10n.library_allRecipes
        : ref.watch(folderNameProvider(id)) ?? '';
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => ref.read(libraryFolderProvider.notifier).select(id),
    );
  }
}

class const _NewFolderChip() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => ActionChip(
    avatar: const Icon(Symbols.create_new_folder_rounded),
    label: Text(context.l10n.library_newFolder),
    onPressed: () async {
      final name = await showFolderNameDialog(
        context,
        title: context.l10n.library_newFolder,
        confirmLabel: context.l10n.library_createFolder,
      );
      if (name == null) return;
      final id = await ref.read(folderEditorProvider.notifier).create(name);
      ref.read(libraryFolderProvider.notifier).select(id);
    },
  );
}
