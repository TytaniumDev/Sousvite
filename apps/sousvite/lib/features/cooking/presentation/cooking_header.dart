import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/cooking/application/cooking_steps.dart';
import 'package:sousvite/features/recipe/recipe.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Where you are: "Prep · Step 2 of 5" (DESIGN_SYSTEM.md §10.3).
class const CookingHeader({
  /// The recipe being cooked.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(cookingProgressProvider(recipeId));
    if (progress == null) return const SizedBox.shrink();
    final sectionId = progress.sectionId;
    final section = sectionId == null
        ? null
        : ref.watch(stepSectionNameProvider(recipeId, sectionId));
    final l10n = context.l10n;
    return Text(
      section == null
          ? l10n.cooking_progress(progress.stepNumber, progress.stepCount)
          : l10n.cooking_sectionProgress(
              section,
              progress.stepNumber,
              progress.stepCount,
            ),
      style: context.appText.cookingSection,
    );
  }
}

/// A thin bar showing progress through the whole recipe.
class const CookingProgressBar({
  /// The recipe being cooked.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(
      cookingProgressProvider(recipeId).select(
        (progress) =>
            progress == null ? 0.0 : progress.stepNumber / progress.stepCount,
      ),
    );
    return ExcludeSemantics(child: LinearProgressIndicator(value: progress));
  }
}

/// Leaves cooking mode, keeping your place.
class const CloseCookingButton({
  /// The recipe being cooked, to go back to when there is nothing to pop.
  required final RecipeId recipeId,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.l10n.cooking_close,
    icon: const Icon(Symbols.close_rounded),
    onPressed: () => context.canPop()
        ? context.pop()
        : context.go(RecipeRoutes.location(recipeId)),
  );
}
