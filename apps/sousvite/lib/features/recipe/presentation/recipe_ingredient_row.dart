import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/recipe/application/recipe_data.dart';
import 'package:sousvite/features/recipe/application/recipe_scale.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/units/unit_words.dart';

/// One ingredient line, scaled and in the chosen units. Rebuilds only
/// when this line or its shown amount changes.
///
/// Cooking mode sets [onChanged] to check lines off.
class const RecipeIngredientRow({
  /// The recipe the line belongs to.
  required final RecipeId recipeId,

  /// The line to show.
  required final IngredientLineId lineId,

  /// Whether the line is checked off. Shown when [onChanged] is set.
  final bool checked = false,

  /// Called with the new value when the row is tapped. Null for a
  /// read-only row.
  final ValueChanged<bool>? onChanged,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(
      ingredientLineProvider(recipeId, lineId).select(
        (line) => line == null
            ? null
            : (
                name: line.name ?? line.rawText,
                countWord: line.countWord,
                preparation: line.preparation,
              ),
      ),
    );
    if (text == null) return const SizedBox.shrink();
    final shown = ref.watch(lineAmountProvider(recipeId, lineId));
    final l10n = context.l10n;
    final amount = shown?.amount;
    final upTo = shown?.upTo;

    // IngredientRow has one amount, so a range ("2–3 cups") is written
    // before the name instead.
    if (amount != null && upTo != null) {
      final from = AmountText.textFor(
        amount.quantity,
        amount.unit == upTo.unit
            ? null
            : l10n.amountWord(amount.unit, text.countWord, amount.quantity),
      );
      final to = AmountText.textFor(
        upTo.quantity,
        l10n.amountWord(upTo.unit, text.countWord, upTo.quantity),
      );
      return IngredientRow(
        name: '$from–$to ${text.name}',
        preparation: text.preparation,
        checked: checked,
        onChanged: onChanged,
      );
    }
    return IngredientRow(
      name: text.name,
      quantity: amount?.quantity,
      unit: amount == null
          ? null
          : l10n.amountWord(amount.unit, text.countWord, amount.quantity),
      preparation: text.preparation,
      checked: checked,
      onChanged: onChanged,
    );
  }
}
