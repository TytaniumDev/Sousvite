import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/grocery/application/grocery_actions.dart';
import 'package:sousvite/features/grocery/application/grocery_providers.dart';
import 'package:sousvite/features/grocery/presentation/add_item_dialog.dart';
import 'package:sousvite/features/grocery/presentation/grocery_list_view.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The grocery list: items grouped by store section, checked ones at the
/// bottom, and items added by hand (PRD 7.7, DESIGN_SYSTEM.md §10.6).
class const GroceryScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.grocery_title),
      actions: const [_MoreMenu()],
    ),
    body: const GroceryListView(),
    floatingActionButton: const _AddItemButton(),
  );
}

class const _AddItemButton() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      FloatingActionButton.extended(
        onPressed: () async {
          final name = await showAddItemDialog(context);
          if (name == null) return;
          await ref.read(groceryActionsProvider).addManualItem(name);
        },
        icon: const Icon(Symbols.add_rounded),
        label: Text(context.l10n.grocery_addItem),
      );
}

/// The overflow menu. Shown only while something is checked off, since
/// that is all it can act on.
class const _MoreMenu() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasChecked = ref.watch(
      groceryViewProvider.select(
        (view) => view.value?.checkedKeys.isNotEmpty ?? false,
      ),
    );
    if (!hasChecked) return const SizedBox.shrink();
    final l10n = context.l10n;
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Symbols.remove_done_rounded),
          onPressed: () => _removeChecked(context, ref),
          child: Text(l10n.grocery_removeChecked),
        ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: l10n.grocery_moreOptions,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: const Icon(Symbols.more_vert_rounded),
      ),
    );
  }

  Future<void> _removeChecked(BuildContext context, WidgetRef ref) async {
    final view = ref.read(groceryViewProvider).value;
    if (view == null) return;
    final items = [
      for (final key in view.checkedKeys) ...view.entries[key]!.items,
    ];
    final actions = ref.read(groceryActionsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    await actions.remove(items);
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.grocery_checkedRemoved),
        action: SnackBarAction(
          label: l10n.common_undo,
          onPressed: () => actions.restore(items),
        ),
      ),
    );
  }
}
