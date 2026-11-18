import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/account/account.dart';
import 'package:sousvite/features/editor/editor.dart';
import 'package:sousvite/features/import/import.dart';
import 'package:sousvite/features/library/application/library_filter.dart';
import 'package:sousvite/features/library/application/library_scope.dart';
import 'package:sousvite/features/library/presentation/folder_grid.dart';
import 'package:sousvite/features/library/presentation/library_search_field.dart';
import 'package:sousvite/features/library/presentation/recipe_grid.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The Library tab (PRD 7.1): a search of every recipe, over the folders
/// as tiles. Every recipe belongs in a folder, so folders are all the page
/// lists (see [LibraryScope]); a tile opens its folder's page. While
/// searching, matching recipes replace the tiles.
class const LibraryScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.library_title),
      actions: const [SyncStatusButton()],
    ),
    body: const CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SignInCalloutCard()),
        SliverToBoxAdapter(child: LibrarySearchField(scope: AllRecipes())),
        _FoldersOrResults(),
        RecipeGridEndSpace(),
      ],
    ),
    floatingActionButton: const AddRecipeButton(),
  );
}

/// The folder tiles, or the recipes matching the search while there is
/// one. Rebuilds only when searching starts or stops. A sliver.
class const _FoldersOrResults() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(isSearchingProvider(const AllRecipes()))
      ? const RecipeGrid(scope: AllRecipes())
      : const FolderGrid();
}

/// Adds a recipe: import it from a link, or write it in the editor.
class const AddRecipeButton({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    onPressed: () => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _AddRecipeSheet(),
    ),
    icon: const Icon(Symbols.add_rounded),
    label: Text(context.l10n.library_addRecipe),
  );
}

class const _AddRecipeSheet() extends StatelessWidget {
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
            onTap: () => open(ImportRoutes.path),
          ),
          ListTile(
            leading: const Icon(Symbols.edit_note_rounded),
            title: Text(l10n.library_writeRecipe),
            onTap: () => open(EditorRoutes.newRecipeLocation()),
          ),
        ],
      ),
    );
  }
}
