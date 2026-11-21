// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_match.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Picks foods for ingredient names from every bundled generic food.
///
/// Waits for the bundled file, which takes a few seconds to load on web:
/// matching before then would find nothing and report every line as
/// unmatched. Kept alive because indexing the foods takes a moment and they
/// never change.

@ProviderFor(foodMatcher)
final foodMatcherProvider = FoodMatcherProvider._();

/// Picks foods for ingredient names from every bundled generic food.
///
/// Waits for the bundled file, which takes a few seconds to load on web:
/// matching before then would find nothing and report every line as
/// unmatched. Kept alive because indexing the foods takes a moment and they
/// never change.

final class FoodMatcherProvider
    extends
        $FunctionalProvider<
          AsyncValue<FoodMatcher>,
          FoodMatcher,
          FutureOr<FoodMatcher>
        >
    with $FutureModifier<FoodMatcher>, $FutureProvider<FoodMatcher> {
  /// Picks foods for ingredient names from every bundled generic food.
  ///
  /// Waits for the bundled file, which takes a few seconds to load on web:
  /// matching before then would find nothing and report every line as
  /// unmatched. Kept alive because indexing the foods takes a moment and they
  /// never change.
  FoodMatcherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodMatcherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodMatcherHash();

  @$internal
  @override
  $FutureProviderElement<FoodMatcher> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FoodMatcher> create(Ref ref) {
    return foodMatcher(ref);
  }
}

String _$foodMatcherHash() => r'098d959ac8006439bb7e017a2d20d98ea5ef3547';

/// Automatic matching with the app's repositories and [foodMatcher].
///
/// Waits for the matcher before watching the repositories: the food
/// repository rebuilds once the bundled foods load, and watching it before
/// that would restart this mid-build and leave callers waiting.

@ProviderFor(autoMatch)
final autoMatchProvider = AutoMatchProvider._();

/// Automatic matching with the app's repositories and [foodMatcher].
///
/// Waits for the matcher before watching the repositories: the food
/// repository rebuilds once the bundled foods load, and watching it before
/// that would restart this mid-build and leave callers waiting.

final class AutoMatchProvider
    extends
        $FunctionalProvider<
          AsyncValue<AutoMatch>,
          AutoMatch,
          FutureOr<AutoMatch>
        >
    with $FutureModifier<AutoMatch>, $FutureProvider<AutoMatch> {
  /// Automatic matching with the app's repositories and [foodMatcher].
  ///
  /// Waits for the matcher before watching the repositories: the food
  /// repository rebuilds once the bundled foods load, and watching it before
  /// that would restart this mid-build and leave callers waiting.
  AutoMatchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoMatchProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoMatchHash();

  @$internal
  @override
  $FutureProviderElement<AutoMatch> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AutoMatch> create(Ref ref) {
    return autoMatch(ref);
  }
}

String _$autoMatchHash() => r'b33a7a1cb6ee0df2f4b084853c64bad66dd67ec0';
