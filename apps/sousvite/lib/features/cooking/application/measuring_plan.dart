import 'package:collection/collection.dart';
import 'package:domain/domain.dart';
import 'package:measuring/measuring.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/features/recipe/recipe.dart';
import 'package:sousvite/features/settings/settings.dart';

part 'measuring_plan.g.dart';

/// Which of your cups and spoons measure one ingredient line's amount as
/// shown, such as ½ Tbsp for 1 ½ tsp (DESIGN_SYSTEM.md §10.3).
///
/// Null when there's nothing to add: the line has no amount or a range,
/// your tools can't measure it (a mass or a count), the amount is already
/// one of your tools (1 cup), or your tools haven't loaded yet.
@riverpod
class LineMeasuringPlan() extends _$LineMeasuringPlan {
  @override
  List<ToolUse>? build(RecipeId recipeId, IngredientLineId lineId) {
    final shown = ref.watch(lineAmountProvider(recipeId, lineId));
    final owned = ref.watch(ownedMeasuringToolsProvider).value;
    if (shown == null || shown.upTo != null || owned == null) return null;
    final amount = shown.amount;
    final plan = decompose(
      amount,
      tools: [for (final tool in owned) Amount(tool.capacity, tool.unit)],
    );
    if (plan case [ToolUse(count: 1, :final tool)] when tool == amount) {
      return null;
    }
    return plan;
  }

  @override
  bool updateShouldNotify(List<ToolUse>? previous, List<ToolUse>? next) =>
      !const ListEquality<ToolUse>().equals(previous, next);
}
