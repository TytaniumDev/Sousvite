import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/nutrition/application/nutrient.dart';
import 'package:sousvite/features/nutrition/application/nutrition_providers.dart';
import 'package:sousvite/features/nutrition/presentation/nutrition_words.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Every nutrient the app shows, in compact density, for the basis the
/// user picked (DESIGN_SYSTEM.md §10.5).
class const NutrientTable({
  /// The recipe whose nutrients this shows.
  required final RecipeId recipeId,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CompactDensity(
    child: Column(
      children: [
        for (final nutrient in Nutrient.values)
          _NutrientLine(
            key: ValueKey(nutrient),
            recipeId: recipeId,
            nutrient: nutrient,
          ),
      ],
    ),
  );
}

/// One nutrient's row. Watches only that nutrient's value.
class const _NutrientLine({
  required final RecipeId recipeId,
  required final Nutrient nutrient,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(
      displayedNutritionProvider(recipeId)
          .select((amounts) => amounts.value?[nutrient] ?? 0),
    );
    final l10n = context.l10n;
    return NutrientRow(
      label: l10n.nutrientName(nutrient),
      value: value,
      unit: l10n.nutrientUnit(nutrient.unit),
      precision: nutrient.unit == .gram ? .grams : .whole,
      indent: nutrient.parent == null ? 0 : 1,
    );
  }
}
