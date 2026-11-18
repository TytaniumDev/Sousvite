import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/library/application/folders.dart';
import 'package:sousvite/features/library/application/library_recipes.dart';
import 'package:sousvite/features/library/application/library_scope.dart';
import 'package:sousvite/features/library/library_routes.dart';
import 'package:sousvite/features/library/presentation/folder_name_dialog.dart';
import 'package:sousvite/features/library/presentation/folder_tile.dart';
import 'package:sousvite/features/library/presentation/scope_title.dart';
import 'package:sousvite/features/library/presentation/sliver_card_rows.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/photos/photos.dart';

/// The library's folders as a grid of tiles: an "Unsorted" tile first
/// while some recipes are in no folder, then each folder, then a tile that
/// makes a new folder. A sliver.
///
/// The grid rebuilds only when folders are added, removed, or reordered,
/// or when the unsorted tile comes or goes; each tile watches its own
/// folder.
class const FolderGrid({super.key}) extends ConsumerWidget {
  /// The narrowest a tile gets before a row holds one fewer. Three fit
  /// across a phone.
  static const double minTileWidth = 100;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(folderIdsProvider);
    final hasUnsorted = ref.watch(
      scopeRecipeCountProvider(const UnsortedRecipes())
          .select((count) => (count ?? 0) > 0),
    );
    if (ids == null) return const SliverToBoxAdapter();
    final scopes = [
      if (hasUnsorted) const UnsortedRecipes(),
      for (final id in ids) FolderRecipes(id),
    ];
    return SliverCardRows(
      itemCount: scopes.length + 1,
      minItemWidth: minTileWidth,
      itemBuilder: (context, index) => index == scopes.length
          ? const _NewFolderTile()
          : LibraryFolderTile(
              key: ValueKey(scopes[index]),
              scope: scopes[index],
            ),
    );
  }
}

/// One folder's tile, or the unsorted tile. Watches only the name, recipe
/// count, and cover photos. Tap opens the folder.
class const LibraryFolderTile({
  /// The folder, or [UnsortedRecipes].
  required final LibraryScope scope,
  super.key,
}) extends ConsumerWidget {
  /// Decodes photos only as wide as a collage needs, in pixels.
  static const int _photoCacheWidth = 400;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(scopeRecipeCountProvider(scope));
    final photoRefs = ref.watch(coverPhotosProvider(scope));
    final photos = ref.watch(recipePhotosProvider);
    return FolderTile(
      title: watchScopeTitle(context, ref, scope),
      countLabel: count == null
          ? null
          : context.l10n.library_recipeCount(count),
      images: [
        for (final photoRef in photoRefs)
          ResizeImage.resizeIfNeeded(
            _photoCacheWidth,
            null,
            photos.imageFor(photoRef),
          ),
      ],
      placeholderIcon: scope is UnsortedRecipes
          ? Symbols.inbox_rounded
          : Symbols.folder_rounded,
      onTap: () => context.go(LibraryRoutes.location(scope)),
    );
  }
}

/// Asks for a name and makes a folder with it.
class const _NewFolderTile() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => FolderTile(
    title: context.l10n.library_newFolder,
    images: const [],
    placeholderIcon: Symbols.create_new_folder_rounded,
    onTap: () async {
      final name = await showFolderNameDialog(
        context,
        title: context.l10n.library_newFolder,
        confirmLabel: context.l10n.library_createFolder,
      );
      if (name == null) return;
      await ref.read(folderEditorProvider.notifier).create(name);
    },
  );
}
