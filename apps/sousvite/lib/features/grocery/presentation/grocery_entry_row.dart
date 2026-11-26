import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/grocery/application/grocery_actions.dart';
import 'package:sousvite/features/grocery/application/grocery_entry.dart';
import 'package:sousvite/features/grocery/application/grocery_providers.dart';
import 'package:sousvite/features/grocery/presentation/grocery_amounts_label.dart';
import 'package:sousvite/features/grocery/presentation/grocery_breakdown_dialog.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/units/unit_words.dart';

/// One combined item on the list. Rebuilds only when its own entry changes.
/// Swipe to remove, with Undo (DESIGN_SYSTEM.md §10.8).
class const GroceryEntryRow({
  /// The entry's key in `GroceryView.entries`.
  required final String entryKey,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(
      groceryViewProvider.select((view) => view.value?.entries[entryKey]),
    );
    if (entry == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final first = entry.amounts.firstOrNull;
    return Dismissible(
      key: ValueKey('dismiss-$entryKey'),
      onDismissed: (_) => _remove(context, ref, entry),
      child: GroceryItemRow(
        name: entry.name,
        checked: entry.checked,
        quantity: first?.quantity,
        unit: first == null
            ? null
            : l10n.unitWord(
                first.unit,
                first.quantity,
                countWord: first.countWord,
              ),
        sourcesLabel: _sourcesLabel(context, ref, entry),
        // A breakdown helps only when a recipe added to the amount.
        onAmountTap: entry.sourceRecipeIds.isEmpty
            ? null
            : () => showGroceryBreakdownDialog(context, entryKey),
        amountTapLabel: entry.sourceRecipeIds.isEmpty
            ? null
            : l10n.grocery_showAmountsByRecipe,
        onChanged: (checked) => ref
            .read(groceryActionsProvider)
            .setChecked(entry.items, checked: checked),
      ),
    );
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    GroceryEntry entry,
  ) async {
    final actions = ref.read(groceryActionsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    await actions.remove(entry.items);
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.grocery_itemRemoved(entry.name)),
        action: SnackBarAction(
          label: l10n.common_undo,
          onPressed: () => actions.restore(entry.items),
        ),
      ),
    );
  }
}

/// The line under an item's name: any amounts in other units, then the
/// recipes it came from ("+ 200 g · Chili, Cornbread").
String? _sourcesLabel(BuildContext context, WidgetRef ref, GroceryEntry entry) {
  final extra = groceryAmountsLabel(context.l10n, entry.amounts.skip(1));
  final titles = [
    for (final recipeId in entry.sourceRecipeIds)
      ?ref.watch(groceryRecipeTitleProvider(recipeId)).value,
  ];
  final parts = [
    if (extra.isNotEmpty) '+ $extra',
    if (titles.isNotEmpty) titles.join(', '),
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}
