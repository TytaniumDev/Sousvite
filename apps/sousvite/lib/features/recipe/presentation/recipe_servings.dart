import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/recipe/application/recipe_data.dart';
import 'package:sousvite/features/recipe/application/recipe_scale.dart';
import 'package:sousvite/l10n/l10n.dart';

/// How many servings the batch makes. Changing it scales every amount;
/// how the batch is divided for nutrition is set separately (PRD 7.1).
class const RecipeServings({
  /// The recipe being scaled.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servings = ref.watch(scaledServingsProvider(recipeId));
    if (servings == null) return const SizedBox.shrink();
    final scaled = ref.watch(
      recipeScaleProvider(recipeId).select((factor) => factor != Quantity.one),
    );
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.space2,
      runSpacing: AppSpacing.space2,
      crossAxisAlignment: .center,
      children: [
        ServingStepper(
          servings: servings,
          unit: l10n.recipe_servings(servings > Quantity.one ? 2 : 1),
          decreaseLabel: l10n.recipe_fewerServings,
          increaseLabel: l10n.recipe_moreServings,
          onChanged: (servings) {
            final from = ref.read(recipeProvider(recipeId)).value?.servings;
            if (from == null) return;
            ref
                .read(recipeScaleProvider(recipeId).notifier)
                .scaleToServings(servings, from: from);
          },
        ),
        if (scaled)
          TextButton(
            onPressed: () =>
                ref.read(recipeScaleProvider(recipeId).notifier).reset(),
            child: Text(l10n.recipe_resetScale),
          ),
      ],
    );
  }
}
