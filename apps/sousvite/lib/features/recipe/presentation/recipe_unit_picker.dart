import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/recipe/application/recipe_units.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Shows amounts as written, in US units, or in metric. Remembered per
/// recipe.
class const RecipeUnitPicker({
  /// The recipe whose units this sets.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return SegmentedButton<UnitSystem>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: .original, label: Text(l10n.recipe_unitsOriginal)),
        ButtonSegment(value: .us, label: Text(l10n.recipe_unitsUs)),
        ButtonSegment(value: .metric, label: Text(l10n.recipe_unitsMetric)),
      ],
      selected: {ref.watch(recipeUnitSystemProvider(recipeId))},
      onSelectionChanged: (selection) => ref
          .read(recipeUnitSystemProvider(recipeId).notifier)
          .select(selection.single),
    );
  }
}
