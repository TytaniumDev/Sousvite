import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/grocery/application/excluded_ingredients.dart';
import 'package:sousvite/features/grocery/application/grocery_actions.dart';
import 'package:sousvite/features/grocery/application/grocery_providers.dart';
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
        child: _AddButton(recipeId: recipeId),
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
        : ListView(
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
      name: line.name ?? line.rawText,
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
      onChanged: (_) => ref
          .read(excludedIngredientsProvider(recipeId).notifier)
          .toggle(lineId),
    );
  }
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
