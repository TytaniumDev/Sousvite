import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/grocery/application/excluded_ingredients.dart';
import 'package:sousvite/features/grocery/application/grocery_actions.dart';
import 'package:sousvite/features/grocery/application/grocery_line_name.dart';
import 'package:sousvite/features/grocery/application/grocery_providers.dart';
import 'package:sousvite/features/grocery/presentation/grocery_amounts_label.dart';
import 'package:sousvite/features/nutrition/nutrition.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/units/unit_words.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// Opens the sheet that adds [recipeId]'s ingredients to the grocery list,
/// each line included unless the user unchecks it (PRD 7.7).
Future<void> showAddToGrocerySheet(BuildContext context, RecipeId recipeId) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => AddToGrocerySheet(recipeId: recipeId),
    );

/// The recipe's ingredient lines with checkboxes, all checked to start,
/// and one Add to list button (DESIGN_SYSTEM.md §10.6).
class const AddToGrocerySheet({
  /// The recipe whose ingredients are offered.
  required final RecipeId recipeId,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: .min,
    crossAxisAlignment: .stretch,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space6),
        child: Text(
          context.l10n.grocery_addToGroceryList,
          style: context.textStyles.titleLarge,
        ),
      ),
      const SizedBox(height: AppSpacing.space2),
      Flexible(child: _Lines(recipeId: recipeId)),
      Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          spacing: AppSpacing.space3,
          children: [
            _CombiningSummary(recipeId: recipeId),
            _AddButton(recipeId: recipeId),
          ],
        ),
      ),
    ],
  );
}

class const _Lines({required final RecipeId recipeId}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(
      groceryRecipeLinesProvider(recipeId).select(
        (lines) =>
            lines.whenData((lines) => [for (final line in lines) line.id]),
      ),
    ),
    data: (lineIds) => lineIds.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(AppSpacing.space6),
            child: Text(context.l10n.grocery_noIngredients),
          )
        : FadingEdges(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final lineId in lineIds)
                  _LineRow(
                    key: ValueKey(lineId),
                    recipeId: recipeId,
                    lineId: lineId,
                  ),
              ],
            ),
          ),
  );
}

/// One ingredient line with its include checkbox. Rebuilds only when this
/// line or its own checkbox changes.
class const _LineRow({
  required final RecipeId recipeId,
  required final IngredientLineId lineId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final line = ref.watch(
      groceryRecipeLinesProvider(recipeId).select(
        (lines) => lines.value?.where((line) => line.id == lineId).firstOrNull,
      ),
    );
    if (line == null) return const SizedBox.shrink();
    final included = ref.watch(
      excludedIngredientsProvider(recipeId)
          .select((excluded) => !excluded.contains(lineId)),
    );
    final quantity = line.quantity;
    return IngredientRow(
      name: groceryNameOf(line),
      quantity: quantity,
      unit: quantity == null
          ? null
          : context.l10n.unitWord(
              line.unit,
              quantity,
              countWord: line.countWord,
            ),
      preparation: line.preparation,
      checked: included,
      checkStyle: .select,
      guide: _CombineHint(
        recipeId: recipeId,
        lineId: lineId,
        name: groceryNameOf(line),
      ),
      onChanged: (_) => ref
          .read(excludedIngredientsProvider(recipeId).notifier)
          .toggle(lineId),
    );
  }
}

/// Under a line whose item is already on the list: what it will add to
/// (DESIGN_SYSTEM.md §10.6). Nothing for a line that starts a new item.
class const _CombineHint({
  required final RecipeId recipeId,
  required final IngredientLineId lineId,
  required final String name,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodId = ref.watch(
      nutritionMatchesProvider(recipeId)
          .select((matches) => matches.value?[lineId]?.foodId),
    );
    final amounts = ref.watch(
      groceryViewProvider.select(
        (view) => view.value?.entryFor(name, foodId: foodId)?.amounts,
      ),
    );
    if (amounts == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final label = groceryAmountsLabel(l10n, amounts);
    return _CombineNote(
      text: amounts.isEmpty
          ? l10n.grocery_alreadyOnList
          : amounts.any((amount) => amount.approximate)
          ? l10n.grocery_addsToAbout(label)
          : l10n.grocery_addsTo(label),
      style: context.textStyles.bodySmall,
      iconSize: _CombineNote.smallIconSize,
    );
  }
}

/// How many chosen lines add to items already on the list. Nothing when
/// none do.
class const _CombiningSummary({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(groceryCombiningLineCountProvider(recipeId));
    if (count == 0) return const SizedBox.shrink();
    return _CombineNote(
      text: context.l10n.grocery_combiningCount(count),
      style: context.textStyles.bodyMedium,
      iconSize: _CombineNote.bodyIconSize,
    );
  }
}

/// The merge symbol, then [text] in `on-surface-variant`.
class const _CombineNote({
  required final String text,
  required final TextStyle? style,
  required final double iconSize,
}) extends StatelessWidget {
  /// The icon beside body text (§7).
  static const double bodyIconSize = 20;

  /// The icon beside a small hint line, as on a status chip.
  static const double smallIconSize = 16;

  @override
  Widget build(BuildContext context) => Row(
    spacing: AppSpacing.space1,
    children: [
      Icon(
        Symbols.merge_rounded,
        size: iconSize,
        color: context.colors.primary,
      ),
      Flexible(
        child: Text(
          text,
          style: style?.copyWith(color: context.colors.onSurfaceVariant),
        ),
      ),
    ],
  );
}

class const _AddButton({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the selection while the sheet is open, even with no row
    // watching it yet.
    ref.watch(excludedIngredientsProvider(recipeId));
    final hasLines = ref.watch(
      groceryRecipeLinesProvider(recipeId)
          .select((lines) => lines.value?.isNotEmpty ?? false),
    );
    return FilledButton(
      onPressed: hasLines ? () => _add(context, ref) : null,
      child: Text(context.l10n.grocery_addToList),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final lines = ref.read(groceryRecipeLinesProvider(recipeId)).value ?? [];
    final excluded = ref.read(excludedIngredientsProvider(recipeId));
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final added = context.l10n.grocery_addedToList;
    await ref.read(groceryActionsProvider).addFromRecipe(recipeId, [
      for (final line in lines)
        if (!excluded.contains(line.id)) line,
    ]);
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(added)));
  }
}
