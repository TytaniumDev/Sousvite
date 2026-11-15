// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(nutritionActions)
final nutritionActionsProvider = NutritionActionsProvider._();

final class NutritionActionsProvider
    extends
        $FunctionalProvider<
          NutritionActions,
          NutritionActions,
          NutritionActions
        >
    with $Provider<NutritionActions> {
  NutritionActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nutritionActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nutritionActionsHash();

  @$internal
  @override
  $ProviderElement<NutritionActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NutritionActions create(Ref ref) {
    return nutritionActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NutritionActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NutritionActions>(value),
    );
  }
}

String _$nutritionActionsHash() => r'd6e0315460a206582675264765613f80566370c6';
