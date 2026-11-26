import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/grocery/application/grocery_actions.dart';
import 'package:sousvite/features/grocery/application/grocery_entry.dart';
import 'package:sousvite/features/grocery/application/grocery_food_merges.dart';
import 'package:sousvite/features/grocery/application/grocery_providers.dart';
import 'package:sousvite/features/grocery/application/grocery_sources.dart';
import 'package:sousvite/features/grocery/presentation/combine_note.dart';
import 'package:sousvite/features/grocery/presentation/grocery_amounts_label.dart';
import 'package:sousvite/features/recipe/recipe.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Opens the dialog that shows how much of the entry at [entryKey] each
/// recipe needs. Tapping outside it or Done closes it.
Future<void> showGroceryBreakdownDialog(
  BuildContext context,
  String entryKey,
) => showDialog<void>(
  context: context,
  builder: (_) => GroceryBreakdownDialog(entryKey: entryKey),
);

/// One grocery entry's total, then each recipe's share of it, with the
/// part added by hand last (DESIGN_SYSTEM.md §10.6). Tapping a recipe
/// opens it. Under them, each name that joined only by matching the same
/// food, with a button that separates it.
class const GroceryBreakdownDialog({
  /// The entry's key in `GroceryView.entries`.
  required final String entryKey,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: _Name(entryKey: entryKey),
    contentPadding: const EdgeInsets.only(top: AppSpacing.space2),
    content: FadingEdges(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            _Total(entryKey: entryKey),
            _Sources(entryKey: entryKey),
            _FoodMerges(entryKey: entryKey),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(context.l10n.grocery_done),
      ),
    ],
  );
}

/// The dialog's horizontal padding, matching its title (§9.2).
const double _inset = AppSpacing.space6;

class const _Name({required final String entryKey}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Text(
    ref.watch(
          groceryViewProvider.select(
            (view) => view.value?.entries[entryKey]?.name,
          ),
        ) ??
        '',
  );
}

/// Every recipe's amounts added up: "⅜ cup + 200 g".
class const _Total({required final String entryKey}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amounts = ref.watch(
      groceryViewProvider.select(
        (view) => view.value?.entries[entryKey]?.amounts,
      ),
    );
    if (amounts == null || amounts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _inset),
      child: Text(
        amounts.any((amount) => amount.approximate)
            ? context.l10n.grocery_aboutAmount(
                groceryAmountsLabel(context.l10n, amounts),
              )
            : groceryAmountsLabel(context.l10n, amounts),
        style: context.appText.numberLarge,
      ),
    );
  }
}

/// A heading with the recipe count, then one row per recipe.
class const _Sources({required final String entryKey}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(
      groceryViewProvider.select((view) => view.value?.entries[entryKey]),
    );
    if (entry == null) return const SizedBox.shrink();
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            _inset,
            AppSpacing.space6,
            _inset,
            AppSpacing.space1,
          ),
          child: Text(
            context.l10n.grocery_inRecipes(entry.sourceRecipeIds.length),
            style: context.textStyles.titleSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        for (final source in grocerySources(entry))
          _SourceRow(
            key: ValueKey(source.recipeId),
            recipeId: source.recipeId,
            amounts: source.amounts,
            names: source.otherNames,
          ),
      ],
    );
  }
}

/// One recipe's name and how much it needs, or the part added by hand
/// when [recipeId] is null. Under it, what the recipe calls the item when
/// that isn't the entry's name ("granulated sugar").
class const _SourceRow({
  required final RecipeId? recipeId,
  required final List<GroceryAmount> amounts,
  required final List<String> names,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recipeId = this.recipeId;
    final l10n = context.l10n;
    return PaddedInkWell(
      onTap: recipeId == null ? null : () => _open(context, recipeId),
      horizontal: _inset,
      vertical: AppSpacing.space3,
      child: Row(
        spacing: AppSpacing.space3,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                if (recipeId == null)
                  Text(
                    l10n.grocery_addedByHand,
                    style: context.textStyles.titleMedium,
                  )
                else
                  _RecipeTitle(recipeId: recipeId),
                if (names.isNotEmpty)
                  Text(
                    names.join(', '),
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            groceryAmountsLabel(l10n, amounts),
            style: context.textStyles.bodyLarge,
          ),
          if (recipeId != null)
            Icon(
              Symbols.chevron_right_rounded,
              color: context.colors.onSurfaceVariant,
            ),
        ],
      ),
    );
  }

  void _open(BuildContext context, RecipeId recipeId) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    unawaited(router.push<void>(RecipeRoutes.location(recipeId)));
  }
}

class const _RecipeTitle({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Text(
    ref.watch(groceryRecipeTitleProvider(recipeId)).value ?? '',
    style: context.textStyles.titleMedium,
  );
}

/// One note per name that joined the entry by food. Nothing when none did.
class const _FoodMerges({required final String entryKey})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(
      groceryViewProvider.select((view) => view.value?.entries[entryKey]),
    );
    if (entry == null) return const SizedBox.shrink();
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        for (final merge in groceryFoodMerges(entry))
          _FoodMergeNote(
            key: ValueKey(merge.name),
            merge: merge,
            entryName: entry.name,
          ),
      ],
    );
  }
}

/// "Combined granulated sugar with sugar", then Separate. Separating
/// closes the dialog, because the entry it shows changes, and offers Undo.
class const _FoodMergeNote({
  required final GroceryFoodMerge merge,
  required final String entryName,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsetsDirectional.only(
      start: _inset,
      end: AppSpacing.space3,
    ),
    child: Row(
      spacing: AppSpacing.space2,
      children: [
        Expanded(
          child: CombineNote(
            text: context.l10n.grocery_combinedWith(merge.name, entryName),
            style: context.textStyles.bodyMedium,
            iconSize: CombineNote.bodyIconSize,
          ),
        ),
        TextButton(
          onPressed: () => unawaited(_separate(context, ref)),
          child: Text(context.l10n.grocery_separate),
        ),
      ],
    ),
  );

  Future<void> _separate(BuildContext context, WidgetRef ref) async {
    final actions = ref.read(groceryActionsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final items = merge.items;
    Navigator.of(context).pop();
    await actions.separate(items);
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.grocery_separated(merge.name)),
        action: SnackBarAction(
          label: l10n.common_undo,
          onPressed: () => actions.restore(items),
        ),
      ),
    );
  }
}
