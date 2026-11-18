import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/nutrition/application/nutrient.dart';
import 'package:sousvite/features/nutrition/application/nutrition_basis.dart';
import 'package:sousvite/features/nutrition/application/nutrition_providers.dart';
import 'package:sousvite/features/nutrition/nutrition_routes.dart';
import 'package:sousvite/features/nutrition/presentation/fix_all_button.dart';
import 'package:sousvite/features/nutrition/presentation/nutrition_words.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// A recipe's calories and macros, per serving or per batch, with a count
/// of unmatched ingredients so totals are never silently wrong (PRD 7.4,
/// DESIGN_SYSTEM.md §10.5). The recipe page shows it in its Nutrition
/// section.
class const NutritionSummary({
  /// The recipe whose nutrition this shows.
  required final RecipeId recipeId,

  /// Whether the unmatched count links to the nutrition screen. Off on
  /// that screen itself.
  final bool showFixLink = true,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .start,
    spacing: AppSpacing.space3,
    children: [
      _BasisSwitch(recipeId: recipeId),
      _Macros(recipeId: recipeId),
      _UnmatchedNote(recipeId: recipeId, showFixLink: showFixLink),
    ],
  );
}

class const _BasisSwitch({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return BasisToggle(
      basis: ref.watch(nutritionBasisControllerProvider(recipeId)),
      onChanged: ref
          .read(nutritionBasisControllerProvider(recipeId).notifier)
          .select,
      perServingLabel: l10n.nutrition_perServing,
      batchLabel: l10n.nutrition_perBatch,
    );
  }
}

typedef _MacroValues = ({
  double calories,
  double protein,
  double carbs,
  double fat,
});

class const _Macros({required final RecipeId recipeId}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final macros = ref.watch(
      displayedNutritionProvider(recipeId).select(
        (value) => value.whenData<_MacroValues>(
          (amounts) => (
            calories: amounts[Nutrient.calories] ?? 0,
            protein: amounts[Nutrient.protein] ?? 0,
            carbs: amounts[Nutrient.carbs] ?? 0,
            fat: amounts[Nutrient.fat] ?? 0,
          ),
        ),
      ),
    );
    return AsyncValueView(
      value: macros,
      data: (macros) => MacroSummary(
        calories: macros.calories,
        protein: macros.protein,
        carbs: macros.carbs,
        fat: macros.fat,
        basisLabel: _basisLabel(context, ref),
        labels: context.l10n.macroLabels,
      ),
    );
  }

  String _basisLabel(BuildContext context, WidgetRef ref) =>
      context.l10n.basisLabel(
        ref.watch(nutritionBasisControllerProvider(recipeId)),
        ref.watch(
          nutritionServingsProvider(recipeId)
              .select((servings) => servings.value ?? Quantity.one),
        ),
      );
}

class const _UnmatchedNote({
  required final RecipeId recipeId,
  required final bool showFixLink,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
      unmatchedLineIdsProvider(recipeId).select((ids) => ids.value?.length),
    );
    if (count == null || count == 0) return const SizedBox.shrink();
    final l10n = context.l10n;
    final warning = context.appColors.warning;
    return Row(
      spacing: AppSpacing.space2,
      children: [
        Icon(Symbols.warning_rounded, color: warning),
        Expanded(
          child: Text(
            l10n.nutrition_excludesUnmatched(count),
            style: context.textStyles.bodyMedium?.copyWith(color: warning),
          ),
        ),
        FixAllButton(recipeId: recipeId),
        if (showFixLink)
          TextButton(
            onPressed: () => context.push(NutritionRoutes.location(recipeId)),
            child: Text(l10n.nutrition_fix),
          ),
      ],
    );
  }
}
