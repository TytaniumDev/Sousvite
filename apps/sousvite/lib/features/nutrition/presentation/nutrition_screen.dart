import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/nutrition/application/nutrition_actions.dart';
import 'package:sousvite/features/nutrition/application/nutrition_providers.dart';
import 'package:sousvite/features/nutrition/presentation/match_tile.dart';
import 'package:sousvite/features/nutrition/presentation/nutrient_table.dart';
import 'package:sousvite/features/nutrition/presentation/nutrition_summary.dart';
import 'package:sousvite/l10n/l10n.dart';

/// A recipe's full nutrition: the summary, the serving size it divides
/// into, every nutrient, and each ingredient's match, which the user can
/// change (PRD 7.4, DESIGN_SYSTEM.md §10.5).
class const NutritionScreen({required final RecipeId recipeId, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const padding = EdgeInsets.symmetric(horizontal: AppSpacing.space4);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.nutrition_title)),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: padding,
            sliver: SliverList.list(
              children: [
                NutritionSummary(recipeId: recipeId, showFixLink: false),
                const SizedBox(height: AppSpacing.space4),
                _Servings(recipeId: recipeId),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(title: l10n.nutrition_nutrients),
          ),
          SliverPadding(
            padding: padding,
            sliver: SliverToBoxAdapter(
              child: NutrientTable(recipeId: recipeId),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(title: l10n.nutrition_ingredients),
          ),
          _MatchList(recipeId: recipeId),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space8)),
        ],
      ),
    );
  }
}

/// The serving size per-serving nutrition divides into, remembered per
/// recipe (PRD 7.4).
class const _Servings({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servings = ref.watch(nutritionServingsProvider(recipeId)).value;
    if (servings == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(l10n.nutrition_servingSize, style: context.textStyles.titleMedium),
        ServingStepper(
          servings: servings,
          unit: l10n.nutrition_servingsUnit(servings == Quantity.one ? 1 : 2),
          decreaseLabel: l10n.nutrition_fewerServings,
          increaseLabel: l10n.nutrition_moreServings,
          onChanged: (servings) => ref
              .read(nutritionActionsProvider)
              .setServings(
                recipeId,
                servings,
                current: ref.read(nutritionPrefsProvider(recipeId)).value,
              ),
        ),
      ],
    );
  }
}

/// One tile per ingredient line. Rebuilds only when lines are added,
/// removed, or moved; each tile watches its own line.
class const _MatchList({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineIds = ref.watch(nutritionLineIdsProvider(recipeId)).value;
    if (lineIds == null) return const SliverToBoxAdapter();
    if (lineIds.isEmpty) {
      final l10n = context.l10n;
      return SliverToBoxAdapter(
        child: EmptyState(
          icon: Symbols.nutrition_rounded,
          title: l10n.nutrition_noIngredients,
          message: l10n.nutrition_noIngredientsMessage,
        ),
      );
    }
    return SliverList.builder(
      itemCount: lineIds.length,
      itemBuilder: (context, index) => MatchTile(
        key: ValueKey(lineIds[index]),
        recipeId: recipeId,
        lineId: lineIds[index],
      ),
    );
  }
}
