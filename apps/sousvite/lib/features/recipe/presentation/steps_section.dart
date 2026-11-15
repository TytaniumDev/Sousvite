import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/recipe/application/recipe_data.dart';
import 'package:sousvite/features/recipe/application/recipe_outline.dart';
import 'package:sousvite/features/recipe/presentation/section_title.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// The steps, grouped by section and numbered through the whole recipe.
class const StepsSection({
  /// The recipe whose steps this shows.
  required final RecipeId recipeId,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .stretch,
    children: [
      SectionTitle(context.l10n.recipe_steps),
      _StepList(recipeId: recipeId),
    ],
  );
}

/// Rebuilds only when steps are added, removed, moved, or regrouped.
class const _StepList({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(stepOutlineProvider(recipeId)),
    data: (outline) {
      var number = 0;
      return Column(
        crossAxisAlignment: .stretch,
        children: [
          for (final group in outline.groups) ...[
            if (group.sectionId case final sectionId?)
              _StepSectionHeader(
                key: ValueKey(sectionId),
                recipeId: recipeId,
                sectionId: sectionId,
                stepCount: group.stepIds.length,
              ),
            for (final stepId in group.stepIds)
              RecipeStepTile(
                key: ValueKey(stepId),
                recipeId: recipeId,
                stepId: stepId,
                number: ++number,
              ),
          ],
        ],
      );
    },
  );
}

class const _StepSectionHeader({
  required final RecipeId recipeId,
  required final StepSectionId sectionId,
  required final int stepCount,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => SectionHeader(
    title: ref.watch(stepSectionNameProvider(recipeId, sectionId)) ?? '',
    countLabel: context.l10n.recipe_stepCount(stepCount),
  );
}

/// One numbered step. Rebuilds only when its text or number changes.
class const RecipeStepTile({
  /// The recipe the step belongs to.
  required final RecipeId recipeId,

  /// The step to show.
  required final RecipeStepId stepId,

  /// Its number in the whole recipe, from 1.
  required final int number,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(
      recipeStepProvider(recipeId, stepId).select((step) => step?.text ?? ''),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: .start,
          children: [
            SizedBox(
              width: AppSpacing.space8,
              child: Semantics(
                label: context.l10n.recipe_stepLabel(number),
                child: ExcludeSemantics(
                  child: Text(
                    '$number',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: StepText(segments: [StepTextSegment(text)])),
          ],
        ),
      ),
    );
  }
}
