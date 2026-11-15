import 'package:domain/domain.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/editor/editor.dart';
import 'package:sousvite/features/experiments/experiments.dart';
import 'package:sousvite/features/library/library.dart';
import 'package:sousvite/features/sharing/sharing.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The recipe's other actions: edit, folders, experiments, and share
/// (DESIGN_SYSTEM.md §10.1).
class const RecipeMenu({
  /// The recipe these actions apply to.
  required final RecipeId recipeId,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Symbols.edit_rounded),
          onPressed: () => context.push(EditorRoutes.location(recipeId)),
          child: Text(l10n.recipe_edit),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Symbols.folder_rounded),
          onPressed: () => showRecipeFoldersSheet(context, recipeId),
          child: Text(l10n.recipe_folders),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Symbols.science_rounded),
          onPressed: () => context.push(ExperimentsRoutes.location(recipeId)),
          child: Text(l10n.recipe_experiment),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Symbols.share_rounded),
          onPressed: () => context.push(SharingRoutes.location(recipeId)),
          child: Text(l10n.recipe_share),
        ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: l10n.recipe_moreOptions,
        icon: const Icon(Symbols.more_vert_rounded),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
