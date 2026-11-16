// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// USDA through our proxy when Firebase is set up, and Open Food Facts
/// always. Browsers don't let pages set a `User-Agent`, so web sends none.

@ProviderFor(nutritionApi)
final nutritionApiProvider = NutritionApiProvider._();

/// USDA through our proxy when Firebase is set up, and Open Food Facts
/// always. Browsers don't let pages set a `User-Agent`, so web sends none.

final class NutritionApiProvider
    extends $FunctionalProvider<NutritionApi, NutritionApi, NutritionApi>
    with $Provider<NutritionApi> {
  /// USDA through our proxy when Firebase is set up, and Open Food Facts
  /// always. Browsers don't let pages set a `User-Agent`, so web sends none.
  NutritionApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nutritionApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nutritionApiHash();

  @$internal
  @override
  $ProviderElement<NutritionApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NutritionApi create(Ref ref) {
    return nutritionApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NutritionApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NutritionApi>(value),
    );
  }
}

String _$nutritionApiHash() => r'aaf6c9aed765e3127591ada0713e9e3bbef7c82f';
