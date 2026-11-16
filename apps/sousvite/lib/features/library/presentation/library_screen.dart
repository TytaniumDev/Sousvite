import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/editor/editor.dart';
import 'package:sousvite/features/import/import.dart';
import 'package:sousvite/features/library/presentation/folder_chips.dart';
import 'package:sousvite/features/library/presentation/folder_menu.dart';
import 'package:sousvite/features/library/presentation/library_search_field.dart';
import 'package:sousvite/features/library/presentation/recipe_grid.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The Library tab: search, folders, and recipe cards (PRD 7.1).
///
/// Each part watches only its own state, so typing in the search field
/// rebuilds the grid but not the folder chips, and so on.
class const LibraryScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.library_title),
        actions: const [FolderMenu()],
      ),
      body: const Column(
        crossAxisAlignment: .stretch,
        children: [
          LibrarySearchField(),
          SizedBox(height: AppSpacing.space2),
          FolderChips(),
          SizedBox(height: AppSpacing.space2),
          Expanded(child: RecipeGrid()),
        ],
      ),
      floatingActionButton: const AddRecipeButton(),
    );
  }
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
