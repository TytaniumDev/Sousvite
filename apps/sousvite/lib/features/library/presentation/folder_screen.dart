import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/library/application/library_scope.dart';
import 'package:sousvite/features/library/presentation/add_recipe_button.dart';
import 'package:sousvite/features/library/presentation/folder_menu.dart';
import 'package:sousvite/features/library/presentation/library_search_field.dart';
import 'package:sousvite/features/library/presentation/recipe_grid.dart';
import 'package:sousvite/features/library/presentation/scope_title.dart';

/// One folder's page, or the page of recipes in no folder: the name, a
/// search of its recipes, and their cards. Opened from a tile in the
/// library's folder grid.
class const FolderScreen({
  /// The folder, or [UnsortedRecipes].
  required final LibraryScope scope,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scope = this.scope;
    return PageScaffold(
      title: _Title(scope: scope),
      actions: [
        if (scope case FolderRecipes(:final folderId))
          FolderMenu(folderId: folderId),
      ],
      body: FadingEdges(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: LibrarySearchField(scope: scope)),
            RecipeGrid(scope: scope),
            const RecipeGridEndSpace(),
          ],
        ),
      ),
      // New recipes go into a folder, so the unsorted page has no button.
      floatingActionButton: switch (scope) {
        FolderRecipes(:final folderId) => AddRecipeButton(folderId: folderId),
        _ => null,
      },
    );
  }
}

/// The page's title. Watches only a folder's name.
class const _Title({required final LibraryScope scope}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Text(watchScopeTitle(context, ref, scope));
}
