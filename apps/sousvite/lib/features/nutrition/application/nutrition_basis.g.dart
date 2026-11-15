// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_basis.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The basis the user picked for [recipeId]'s nutrition. Starts per
/// serving, the number most people want (PRD 7.4).

@ProviderFor(NutritionBasisController)
final nutritionBasisControllerProvider = NutritionBasisControllerFamily._();

/// The basis the user picked for [recipeId]'s nutrition. Starts per
/// serving, the number most people want (PRD 7.4).
final class NutritionBasisControllerProvider
    extends $NotifierProvider<NutritionBasisController, NutritionBasis> {
  /// The basis the user picked for [recipeId]'s nutrition. Starts per
  /// serving, the number most people want (PRD 7.4).
  NutritionBasisControllerProvider._({
    required NutritionBasisControllerFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'nutritionBasisControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nutritionBasisControllerHash();

  @override
  String toString() {
    return r'nutritionBasisControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  NutritionBasisController create() => NutritionBasisController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NutritionBasis value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NutritionBasis>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NutritionBasisControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nutritionBasisControllerHash() =>
    r'c716588d073a63a5d83e9e85835dcfb6722ac303';

/// The basis the user picked for [recipeId]'s nutrition. Starts per
/// serving, the number most people want (PRD 7.4).

final class NutritionBasisControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          NutritionBasisController,
          NutritionBasis,
          NutritionBasis,
          NutritionBasis,
          RecipeId
        > {
  NutritionBasisControllerFamily._()
    : super(
        retry: null,
        name: r'nutritionBasisControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The basis the user picked for [recipeId]'s nutrition. Starts per
  /// serving, the number most people want (PRD 7.4).

  NutritionBasisControllerProvider call(RecipeId recipeId) =>
      NutritionBasisControllerProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'nutritionBasisControllerProvider';
}

/// The basis the user picked for [recipeId]'s nutrition. Starts per
/// serving, the number most people want (PRD 7.4).

abstract class _$NutritionBasisController extends $Notifier<NutritionBasis> {
  late final _$args = ref.$arg as RecipeId;
  RecipeId get recipeId => _$args;

  NutritionBasis build(RecipeId recipeId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NutritionBasis, NutritionBasis>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NutritionBasis, NutritionBasis>,
              NutritionBasis,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
