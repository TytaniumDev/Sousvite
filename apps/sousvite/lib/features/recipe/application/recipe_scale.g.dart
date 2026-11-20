// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_scale.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How much this recipe is scaled for cooking: 2 is a double batch
/// (PRD 7.6). Shared by the recipe page and cooking mode, so amounts in the
/// steps follow the scaling chosen on the page.
///
/// This is not the serving size that per-serving nutrition divides by;
/// that is remembered in `UserRecipePrefs` (PRD 7.4). The scale lasts while
/// the app runs.

@ProviderFor(RecipeScale)
final recipeScaleProvider = RecipeScaleFamily._();

/// How much this recipe is scaled for cooking: 2 is a double batch
/// (PRD 7.6). Shared by the recipe page and cooking mode, so amounts in the
/// steps follow the scaling chosen on the page.
///
/// This is not the serving size that per-serving nutrition divides by;
/// that is remembered in `UserRecipePrefs` (PRD 7.4). The scale lasts while
/// the app runs.
final class RecipeScaleProvider
    extends $NotifierProvider<RecipeScale, Quantity> {
  /// How much this recipe is scaled for cooking: 2 is a double batch
  /// (PRD 7.6). Shared by the recipe page and cooking mode, so amounts in the
  /// steps follow the scaling chosen on the page.
  ///
  /// This is not the serving size that per-serving nutrition divides by;
  /// that is remembered in `UserRecipePrefs` (PRD 7.4). The scale lasts while
  /// the app runs.
  RecipeScaleProvider._({
    required RecipeScaleFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'recipeScaleProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recipeScaleHash();

  @override
  String toString() {
    return r'recipeScaleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RecipeScale create() => RecipeScale();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Quantity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Quantity>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeScaleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recipeScaleHash() => r'b6a3d87216bc4dc0b84ac8381fc5327b60856279';

/// How much this recipe is scaled for cooking: 2 is a double batch
/// (PRD 7.6). Shared by the recipe page and cooking mode, so amounts in the
/// steps follow the scaling chosen on the page.
///
/// This is not the serving size that per-serving nutrition divides by;
/// that is remembered in `UserRecipePrefs` (PRD 7.4). The scale lasts while
/// the app runs.

final class RecipeScaleFamily extends $Family
    with
        $ClassFamilyOverride<
          RecipeScale,
          Quantity,
          Quantity,
          Quantity,
          RecipeId
        > {
  RecipeScaleFamily._()
    : super(
        retry: null,
        name: r'recipeScaleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// How much this recipe is scaled for cooking: 2 is a double batch
  /// (PRD 7.6). Shared by the recipe page and cooking mode, so amounts in the
  /// steps follow the scaling chosen on the page.
  ///
  /// This is not the serving size that per-serving nutrition divides by;
  /// that is remembered in `UserRecipePrefs` (PRD 7.4). The scale lasts while
  /// the app runs.

  RecipeScaleProvider call(RecipeId recipeId) =>
      RecipeScaleProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'recipeScaleProvider';
}

/// How much this recipe is scaled for cooking: 2 is a double batch
/// (PRD 7.6). Shared by the recipe page and cooking mode, so amounts in the
/// steps follow the scaling chosen on the page.
///
/// This is not the serving size that per-serving nutrition divides by;
/// that is remembered in `UserRecipePrefs` (PRD 7.4). The scale lasts while
/// the app runs.

abstract class _$RecipeScale extends $Notifier<Quantity> {
  late final _$args = ref.$arg as RecipeId;
  RecipeId get recipeId => _$args;

  Quantity build(RecipeId recipeId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Quantity, Quantity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Quantity, Quantity>,
              Quantity,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// How many servings the batch makes at the current scale. Null until the
/// recipe loads.

@ProviderFor(scaledServings)
final scaledServingsProvider = ScaledServingsFamily._();

/// How many servings the batch makes at the current scale. Null until the
/// recipe loads.

final class ScaledServingsProvider
    extends $FunctionalProvider<Quantity?, Quantity?, Quantity?>
    with $Provider<Quantity?> {
  /// How many servings the batch makes at the current scale. Null until the
  /// recipe loads.
  ScaledServingsProvider._({
    required ScaledServingsFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'scaledServingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$scaledServingsHash();

  @override
  String toString() {
    return r'scaledServingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Quantity?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Quantity? create(Ref ref) {
    final argument = this.argument as RecipeId;
    return scaledServings(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Quantity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Quantity?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ScaledServingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$scaledServingsHash() => r'd673e5b863aff183dc7cf57978c2a2c8b9c2ccee';

/// How many servings the batch makes at the current scale. Null until the
/// recipe loads.

final class ScaledServingsFamily extends $Family
    with $FunctionalFamilyOverride<Quantity?, RecipeId> {
  ScaledServingsFamily._()
    : super(
        retry: null,
        name: r'scaledServingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How many servings the batch makes at the current scale. Null until the
  /// recipe loads.

  ScaledServingsProvider call(RecipeId recipeId) =>
      ScaledServingsProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'scaledServingsProvider';
}

/// One line's amount at the current scale, in this recipe's unit system
/// (PRD 7.6). Null while loading, once the line is gone, or when the line
/// has no amount ("salt to taste").
///
/// As written, amounts are shown exactly as the recipe has them. Once
/// scaled or converted, they are rounded to something people can measure.
/// Garlic cloves are shown as jarred garlic while that is on; only those
/// lines watch the setting.

@ProviderFor(lineAmount)
final lineAmountProvider = LineAmountFamily._();

/// One line's amount at the current scale, in this recipe's unit system
/// (PRD 7.6). Null while loading, once the line is gone, or when the line
/// has no amount ("salt to taste").
///
/// As written, amounts are shown exactly as the recipe has them. Once
/// scaled or converted, they are rounded to something people can measure.
/// Garlic cloves are shown as jarred garlic while that is on; only those
/// lines watch the setting.

final class LineAmountProvider
    extends $FunctionalProvider<LineAmount?, LineAmount?, LineAmount?>
    with $Provider<LineAmount?> {
  /// One line's amount at the current scale, in this recipe's unit system
  /// (PRD 7.6). Null while loading, once the line is gone, or when the line
  /// has no amount ("salt to taste").
  ///
  /// As written, amounts are shown exactly as the recipe has them. Once
  /// scaled or converted, they are rounded to something people can measure.
  /// Garlic cloves are shown as jarred garlic while that is on; only those
  /// lines watch the setting.
  LineAmountProvider._({
    required LineAmountFamily super.from,
    required (RecipeId, IngredientLineId) super.argument,
  }) : super(
         retry: null,
         name: r'lineAmountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lineAmountHash();

  @override
  String toString() {
    return r'lineAmountProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<LineAmount?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LineAmount? create(Ref ref) {
    final argument = this.argument as (RecipeId, IngredientLineId);
    return lineAmount(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LineAmount? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LineAmount?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LineAmountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lineAmountHash() => r'371130caf5835ae8b945b47dc1882b42d915f2d4';

/// One line's amount at the current scale, in this recipe's unit system
/// (PRD 7.6). Null while loading, once the line is gone, or when the line
/// has no amount ("salt to taste").
///
/// As written, amounts are shown exactly as the recipe has them. Once
/// scaled or converted, they are rounded to something people can measure.
/// Garlic cloves are shown as jarred garlic while that is on; only those
/// lines watch the setting.

final class LineAmountFamily extends $Family
    with $FunctionalFamilyOverride<LineAmount?, (RecipeId, IngredientLineId)> {
  LineAmountFamily._()
    : super(
        retry: null,
        name: r'lineAmountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One line's amount at the current scale, in this recipe's unit system
  /// (PRD 7.6). Null while loading, once the line is gone, or when the line
  /// has no amount ("salt to taste").
  ///
  /// As written, amounts are shown exactly as the recipe has them. Once
  /// scaled or converted, they are rounded to something people can measure.
  /// Garlic cloves are shown as jarred garlic while that is on; only those
  /// lines watch the setting.

  LineAmountProvider call(RecipeId recipeId, IngredientLineId lineId) =>
      LineAmountProvider._(argument: (recipeId, lineId), from: this);

  @override
  String toString() => r'lineAmountProvider';
}
