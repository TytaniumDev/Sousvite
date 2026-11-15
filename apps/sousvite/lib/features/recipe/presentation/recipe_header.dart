import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/recipe/application/recipe_data.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/format/duration_label.dart';

/// The recipe's name, then where it came from and how long it takes.
class const RecipeHeader({
  /// The recipe whose name this shows.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final header = ref.watch(
      recipeProvider(recipeId).select((recipe) {
        final value = recipe.value;
        if (value == null) return null;
        return (
          title: value.title,
          source: value.sourceName,
          prep: value.prepTime,
          cook: value.cookTime,
          total: value.totalTime,
        );
      }),
    );
    if (header == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final details = [
      if (header.source case final source?) l10n.recipe_source(source),
      if (header.prep case final prep?)
        l10n.recipe_prepTime(l10n.durationLabel(prep)),
      if (header.cook case final cook?)
        l10n.recipe_cookTime(l10n.durationLabel(cook)),
      if (header.total case final total?)
        l10n.recipe_totalTime(l10n.durationLabel(total)),
    ];
    return Column(
      crossAxisAlignment: .start,
      children: [
        Semantics(
          header: true,
          child: Text(header.title, style: context.textStyles.headlineLarge),
        ),
        if (details.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space2),
          Text(
            details.join(' · '),
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
