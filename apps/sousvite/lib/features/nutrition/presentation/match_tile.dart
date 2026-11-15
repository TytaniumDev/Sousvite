import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/nutrition/application/nutrition_providers.dart';
import 'package:sousvite/features/nutrition/presentation/change_match_sheet.dart';
import 'package:sousvite/features/nutrition/presentation/nutrition_words.dart';
import 'package:sousvite/l10n/l10n.dart';

/// An ingredient line, the food it is matched to, and where that food's
/// nutrition came from. Tapping it changes the match (PRD 7.4).
class const MatchTile({
  /// The recipe the line belongs to.
  required final RecipeId recipeId,

  /// The line this tile shows.
  required final IngredientLineId lineId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(
      nutritionLinesProvider(recipeId).select(
        (lines) => lines.value
            ?.where((line) => line.id == lineId)
            .firstOrNull
            ?.rawText,
      ),
    );
    final match = ref.watch(
      nutritionMatchesProvider(recipeId)
          .select((matches) => matches.value?[lineId]),
    );
    final status = matchStatusOf(match);
    return ListTile(
      title: Text(text ?? ''),
      subtitle: match == null
          ? Text(context.l10n.nutrition_notCounted)
          : _MatchedFood(match: match),
      trailing: MatchStatusChip(
        status: status,
        label: context.l10n.matchStatus(status),
      ),
      onTap: () =>
          showChangeMatchSheet(context, recipeId: recipeId, lineId: lineId),
    );
  }
}

/// "Chickpeas, canned · 240 g".
class const _MatchedFood({required final NutritionMatch match})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(
      nutritionFoodProvider(match.foodId).select((food) => food.value?.name),
    );
    return Text(
      context.l10n.nutrition_matchedFood(
        name ?? '',
        NutrientPrecision.grams.format(match.gramWeight),
      ),
    );
  }
}
