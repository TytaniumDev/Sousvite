// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_timers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The timers running while cooking [recipeId], by [timerKey]. Kept while
/// the app runs, so timers keep going on every step and after leaving
/// (DESIGN_SYSTEM.md §10.3).

@ProviderFor(CookingTimers)
final cookingTimersProvider = CookingTimersFamily._();

/// The timers running while cooking [recipeId], by [timerKey]. Kept while
/// the app runs, so timers keep going on every step and after leaving
/// (DESIGN_SYSTEM.md §10.3).
final class CookingTimersProvider
    extends $NotifierProvider<CookingTimers, Map<String, RunningTimer>> {
  /// The timers running while cooking [recipeId], by [timerKey]. Kept while
  /// the app runs, so timers keep going on every step and after leaving
  /// (DESIGN_SYSTEM.md §10.3).
  CookingTimersProvider._({
    required CookingTimersFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'cookingTimersProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cookingTimersHash();

  @override
  String toString() {
    return r'cookingTimersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CookingTimers create() => CookingTimers();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, RunningTimer> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, RunningTimer>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CookingTimersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cookingTimersHash() => r'b4573c9db8ac3e37f97b6bd6321dbae62142cd9d';

/// The timers running while cooking [recipeId], by [timerKey]. Kept while
/// the app runs, so timers keep going on every step and after leaving
/// (DESIGN_SYSTEM.md §10.3).

final class CookingTimersFamily extends $Family
    with
        $ClassFamilyOverride<
          CookingTimers,
          Map<String, RunningTimer>,
          Map<String, RunningTimer>,
          Map<String, RunningTimer>,
          RecipeId
        > {
  CookingTimersFamily._()
    : super(
        retry: null,
        name: r'cookingTimersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The timers running while cooking [recipeId], by [timerKey]. Kept while
  /// the app runs, so timers keep going on every step and after leaving
  /// (DESIGN_SYSTEM.md §10.3).

  CookingTimersProvider call(RecipeId recipeId) =>
      CookingTimersProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'cookingTimersProvider';
}

/// The timers running while cooking [recipeId], by [timerKey]. Kept while
/// the app runs, so timers keep going on every step and after leaving
/// (DESIGN_SYSTEM.md §10.3).

abstract class _$CookingTimers extends $Notifier<Map<String, RunningTimer>> {
  late final _$args = ref.$arg as RecipeId;
  RecipeId get recipeId => _$args;

  Map<String, RunningTimer> build(RecipeId recipeId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<Map<String, RunningTimer>, Map<String, RunningTimer>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, RunningTimer>, Map<String, RunningTimer>>,
              Map<String, RunningTimer>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// When the timer [key] started, or null while it is idle. Only that
/// timer's chip rebuilds when it changes.

@ProviderFor(timerStartedAt)
final timerStartedAtProvider = TimerStartedAtFamily._();

/// When the timer [key] started, or null while it is idle. Only that
/// timer's chip rebuilds when it changes.

final class TimerStartedAtProvider
    extends $FunctionalProvider<DateTime?, DateTime?, DateTime?>
    with $Provider<DateTime?> {
  /// When the timer [key] started, or null while it is idle. Only that
  /// timer's chip rebuilds when it changes.
  TimerStartedAtProvider._({
    required TimerStartedAtFamily super.from,
    required (RecipeId, String) super.argument,
  }) : super(
         retry: null,
         name: r'timerStartedAtProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$timerStartedAtHash();

  @override
  String toString() {
    return r'timerStartedAtProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime? create(Ref ref) {
    final argument = this.argument as (RecipeId, String);
    return timerStartedAt(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TimerStartedAtProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$timerStartedAtHash() => r'75d2407796e5fefc470ca6c168c8ad2be85e6582';

/// When the timer [key] started, or null while it is idle. Only that
/// timer's chip rebuilds when it changes.

final class TimerStartedAtFamily extends $Family
    with $FunctionalFamilyOverride<DateTime?, (RecipeId, String)> {
  TimerStartedAtFamily._()
    : super(
        retry: null,
        name: r'timerStartedAtProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// When the timer [key] started, or null while it is idle. Only that
  /// timer's chip rebuilds when it changes.

  TimerStartedAtProvider call(RecipeId recipeId, String key) =>
      TimerStartedAtProvider._(argument: (recipeId, key), from: this);

  @override
  String toString() => r'timerStartedAtProvider';
}
