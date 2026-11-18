// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_match.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Picks foods for ingredient names from every bundled generic food.
///
/// Kept alive because indexing the foods takes a moment and they never
/// change; it's rebuilt once the bundled file has loaded.

@ProviderFor(foodMatcher)
final foodMatcherProvider = FoodMatcherProvider._();

/// Picks foods for ingredient names from every bundled generic food.
///
/// Kept alive because indexing the foods takes a moment and they never
/// change; it's rebuilt once the bundled file has loaded.

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
  /// Kept alive because indexing the foods takes a moment and they never
  /// change; it's rebuilt once the bundled file has loaded.
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

String _$foodMatcherHash() => r'd17eac02e716a45f59d23e1f31d26572333c3d93';

/// Automatic matching with the app's repositories and [foodMatcher].

@ProviderFor(autoMatch)
final autoMatchProvider = AutoMatchProvider._();

/// Automatic matching with the app's repositories and [foodMatcher].

final class AutoMatchProvider
    extends
        $FunctionalProvider<
          AsyncValue<AutoMatch>,
          AutoMatch,
          FutureOr<AutoMatch>
        >
    with $FutureModifier<AutoMatch>, $FutureProvider<AutoMatch> {
  /// Automatic matching with the app's repositories and [foodMatcher].
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

String _$autoMatchHash() => r'3b21ebe0176f1a68e566ce22e5e8ae41b1f01368';
