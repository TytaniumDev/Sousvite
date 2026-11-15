// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'excluded_ingredients.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The ingredient lines left out when adding [recipeId] to the grocery
/// list. Every line is included until the user unchecks it (PRD 7.7).

@ProviderFor(ExcludedIngredients)
final excludedIngredientsProvider = ExcludedIngredientsFamily._();

/// The ingredient lines left out when adding [recipeId] to the grocery
/// list. Every line is included until the user unchecks it (PRD 7.7).
final class ExcludedIngredientsProvider
    extends $NotifierProvider<ExcludedIngredients, Set<IngredientLineId>> {
  /// The ingredient lines left out when adding [recipeId] to the grocery
  /// list. Every line is included until the user unchecks it (PRD 7.7).
  ExcludedIngredientsProvider._({
    required ExcludedIngredientsFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'excludedIngredientsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$excludedIngredientsHash();

  @override
  String toString() {
    return r'excludedIngredientsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ExcludedIngredients create() => ExcludedIngredients();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<IngredientLineId> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<IngredientLineId>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExcludedIngredientsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$excludedIngredientsHash() =>
    r'e810b9804ca956dcc5bb54be0543c93b36531b2d';

/// The ingredient lines left out when adding [recipeId] to the grocery
/// list. Every line is included until the user unchecks it (PRD 7.7).

final class ExcludedIngredientsFamily extends $Family
    with
        $ClassFamilyOverride<
          ExcludedIngredients,
          Set<IngredientLineId>,
          Set<IngredientLineId>,
          Set<IngredientLineId>,
          RecipeId
        > {
  ExcludedIngredientsFamily._()
    : super(
        retry: null,
        name: r'excludedIngredientsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The ingredient lines left out when adding [recipeId] to the grocery
  /// list. Every line is included until the user unchecks it (PRD 7.7).

  ExcludedIngredientsProvider call(RecipeId recipeId) =>
      ExcludedIngredientsProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'excludedIngredientsProvider';
}

/// The ingredient lines left out when adding [recipeId] to the grocery
/// list. Every line is included until the user unchecks it (PRD 7.7).

abstract class _$ExcludedIngredients extends $Notifier<Set<IngredientLineId>> {
  late final _$args = ref.$arg as RecipeId;
  RecipeId get recipeId => _$args;

  Set<IngredientLineId> build(RecipeId recipeId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<IngredientLineId>, Set<IngredientLineId>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<IngredientLineId>, Set<IngredientLineId>>,
              Set<IngredientLineId>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
