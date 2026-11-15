import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/cooking/cooking.dart';
import 'package:sousvite/features/grocery/grocery.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Start cooking, the page's one primary action, then add to the grocery
/// list (DESIGN_SYSTEM.md §10.1).
class const RecipeActions({
  /// The recipe these actions apply to.
  required final RecipeId recipeId,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.space2,
      runSpacing: AppSpacing.space2,
      children: [
        FilledButton.icon(
          icon: const Icon(Symbols.play_arrow_rounded),
          label: Text(l10n.recipe_startCooking),
          onPressed: () => context.push(CookingRoutes.location(recipeId)),
        ),
        FilledButton.tonalIcon(
          icon: const Icon(Symbols.add_shopping_cart_rounded),
          label: Text(l10n.recipe_addToGrocery),
          onPressed: () => showAddToGrocerySheet(context, recipeId),
        ),
      ],
    );
  }
}
