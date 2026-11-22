import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/cooking/application/cooking_steps.dart';
import 'package:sousvite/features/cooking/presentation/cooking_header.dart';
import 'package:sousvite/features/cooking/presentation/cooking_pager.dart';
import 'package:sousvite/features/cooking/presentation/keep_screen_on.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// Cooking mode: one step at a time in the high-contrast cooking theme,
/// with the screen kept on (DESIGN_SYSTEM.md §10.3, §10.4).
class const CookingScreen({
  /// The recipe being cooked.
  required final RecipeId recipeId,
  super.key,
}) extends StatelessWidget {
  /// Cooking text follows the system text size up to this, so the layout
  /// never breaks (§10.4).
  static const maxTextScale = 1.5;

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.cooking(Theme.of(context).brightness),
    child: MediaQuery.withClampedTextScaling(
      maxScaleFactor: maxTextScale,
      child: KeepScreenOn(
        child: PageScaffold(
          leading: CloseCookingButton(recipeId: recipeId),
          title: CookingHeader(recipeId: recipeId),
          // The step count and Close stay in view while cooking.
          hideOnScroll: false,
          body: _CookingSteps(recipeId: recipeId),
        ),
      ),
    ),
  );
}

/// Rebuilds only when steps are added, removed, or moved.
class const _CookingSteps({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(cookingStepsProvider(recipeId)),
    data: (steps) => steps.isEmpty
        ? EmptyState(
            icon: Symbols.format_list_numbered_rounded,
            title: context.l10n.cooking_noStepsTitle,
            message: context.l10n.cooking_noStepsMessage,
          )
        : CookingPager(
            recipeId: recipeId,
            stepIds: [for (final step in steps) step.stepId],
          ),
  );
}
