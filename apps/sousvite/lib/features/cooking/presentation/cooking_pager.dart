import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/cooking/application/checked_ingredients.dart';
import 'package:sousvite/features/cooking/application/cooking_steps.dart';
import 'package:sousvite/features/cooking/presentation/cooking_header.dart';
import 'package:sousvite/features/cooking/presentation/cooking_step_page.dart';
import 'package:sousvite/features/cooking/presentation/timer_tray.dart';
import 'package:sousvite/features/recipe/recipe.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The steps, one page each: swipe anywhere, or use the Back and Next
/// buttons at the bottom (DESIGN_SYSTEM.md §10.3).
class const CookingPager({
  /// The recipe being cooked.
  required final RecipeId recipeId,

  /// Every step, in cooking order.
  required final List<RecipeStepId> stepIds,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<CookingPager> createState() => _CookingPagerState();
}

class _CookingPagerState() extends ConsumerState<CookingPager> {
  late final PageController _pages = PageController(
    initialPage: ref
        .read(cookingPositionProvider(widget.recipeId))
        .clamp(0, widget.stepIds.length - 1),
  );

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _showStep(int index) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(index);
      return Future.value();
    }
    final curve = SpringCurve(AppMotion.spatialDefault);
    return _pages.animateToPage(index, duration: curve.duration, curve: curve);
  }

  void _finish() {
    ref.read(cookingPositionProvider(widget.recipeId).notifier).reset();
    ref.read(checkedIngredientsProvider(widget.recipeId).notifier).clear();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RecipeRoutes.location(widget.recipeId));
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      CookingProgressBar(recipeId: widget.recipeId),
      Expanded(
        child: PageView.builder(
          controller: _pages,
          itemCount: widget.stepIds.length,
          onPageChanged: ref
              .read(cookingPositionProvider(widget.recipeId).notifier)
              .goTo,
          itemBuilder: (_, index) => CookingStepPage(
            key: ValueKey(widget.stepIds[index]),
            recipeId: widget.recipeId,
            stepId: widget.stepIds[index],
          ),
        ),
      ),
      TimerTray(recipeId: widget.recipeId),
      CookingNavBar(
        recipeId: widget.recipeId,
        stepCount: widget.stepIds.length,
        onShowStep: _showStep,
        onDone: _finish,
      ),
    ],
  );
}

/// Large Back and Next buttons in the thumb zone. The last step's Next
/// becomes Done.
class const CookingNavBar({
  /// The recipe being cooked.
  required final RecipeId recipeId,

  /// How many steps there are.
  required final int stepCount,

  /// Shows the step at an index.
  required final ValueChanged<int> onShowStep,

  /// Called by Done on the last step.
  required final VoidCallback onDone,
  super.key,
}) extends ConsumerWidget {
  /// At least 64 dp tall, for messy hands (DESIGN_SYSTEM.md §10.3, §12).
  static const buttonHeight = 64.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref
        .watch(cookingPositionProvider(recipeId))
        .clamp(0, stepCount - 1);
    final isLast = index == stepCount - 1;
    final l10n = context.l10n;
    const size = Size.fromHeight(buttonHeight);
    return SafeArea(
      top: false,
      child: ReadingColumn(
        builder: (context, insets) => Padding(
          padding: insets + const EdgeInsets.all(AppSpacing.space4),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: size),
                  onPressed: index == 0 ? null : () => onShowStep(index - 1),
                  child: Text(l10n.cooking_back),
                ),
              ),
              const SizedBox(width: AppSpacing.space4),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: size),
                  onPressed: isLast ? onDone : () => onShowStep(index + 1),
                  child: Text(isLast ? l10n.cooking_done : l10n.cooking_next),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
