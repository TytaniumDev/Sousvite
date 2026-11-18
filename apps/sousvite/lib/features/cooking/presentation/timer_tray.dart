import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/cooking/application/cooking_timers.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Running timers, pinned above Back and Next so they stay visible on
/// every step (DESIGN_SYSTEM.md §10.3). Hidden when none are running.
class const TimerTray({
  /// The recipe being cooked.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final running = ref.watch(cookingTimersProvider(recipeId));
    if (running.isEmpty) return const SizedBox.shrink();
    final timers = ref.read(cookingTimersProvider(recipeId).notifier);
    return ReadingColumn(
      builder: (context, insets) => Padding(
        padding:
            insets + const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
        child: Align(
          alignment: .centerLeft,
          child: Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: [
              for (final MapEntry(:key, :value) in running.entries)
                TimerChip(
                  key: ValueKey(key),
                  label: value.label,
                  duration: value.duration,
                  startedAt: value.startedAt,
                  doneLabel: context.l10n.cooking_timerDone,
                  onStart: () {},
                  onStop: () => timers.stop(key),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
