// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bundled_foods.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The bundled USDA foods, opened from the app's asset.
///
/// Loads in the background, so the first frame doesn't wait for the 9 MB
/// file; the food repository reads only cached foods until it has loaded.

@ProviderFor(bundledFoods)
final bundledFoodsProvider = BundledFoodsProvider._();

/// The bundled USDA foods, opened from the app's asset.
///
/// Loads in the background, so the first frame doesn't wait for the 9 MB
/// file; the food repository reads only cached foods until it has loaded.

final class BundledFoodsProvider
    extends
        $FunctionalProvider<
          AsyncValue<BundledFoods>,
          BundledFoods,
          FutureOr<BundledFoods>
        >
    with $FutureModifier<BundledFoods>, $FutureProvider<BundledFoods> {
  /// The bundled USDA foods, opened from the app's asset.
  ///
  /// Loads in the background, so the first frame doesn't wait for the 9 MB
  /// file; the food repository reads only cached foods until it has loaded.
  BundledFoodsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bundledFoodsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bundledFoodsHash();

  @$internal
  @override
  $FutureProviderElement<BundledFoods> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BundledFoods> create(Ref ref) {
    return bundledFoods(ref);
  }
}

String _$bundledFoodsHash() => r'f1a50a1504fe4485db1c6f920fb8b4afe590d078';
