import 'package:clock/clock.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cooking_timers.g.dart';

/// A step timer that has been started.
typedef RunningTimer = ({String label, Duration duration, DateTime startedAt});

/// The timers running while cooking [recipeId], by [timerKey]. Kept while
/// the app runs, so timers keep going on every step and after leaving
/// (DESIGN_SYSTEM.md §10.3).
@Riverpod(keepAlive: true)
class CookingTimers() extends _$CookingTimers {
  @override
  Map<String, RunningTimer> build(RecipeId recipeId) => const {};

  /// Starts the timer [key], showing [label] and counting down [duration].
  void start(String key, {required String label, required Duration duration}) =>
      state = {
        ...state,
        key: (label: label, duration: duration, startedAt: clock.now()),
      };

  /// Cancels or dismisses the timer [key].
  void stop(String key) => state = {
    for (final MapEntry(key: k, :value) in state.entries)
      if (k != key) k: value,
  };
}

/// The key of the [index]th timer found in [stepId].
String timerKey(RecipeStepId stepId, int index) => '${stepId.value}#$index';

/// When the timer [key] started, or null while it is idle. Only that
/// timer's chip rebuilds when it changes.
@riverpod
DateTime? timerStartedAt(Ref ref, RecipeId recipeId, String key) =>
    ref.watch(cookingTimersProvider(recipeId).select((t) => t[key]?.startedAt));
