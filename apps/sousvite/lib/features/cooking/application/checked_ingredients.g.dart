// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checked_ingredients.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The ingredient lines checked off while cooking [recipeId]. Kept while
/// the app runs, like the cook's place.

@ProviderFor(CheckedIngredients)
final checkedIngredientsProvider = CheckedIngredientsFamily._();

/// The ingredient lines checked off while cooking [recipeId]. Kept while
/// the app runs, like the cook's place.
final class CheckedIngredientsProvider
    extends $NotifierProvider<CheckedIngredients, Set<IngredientLineId>> {
  /// The ingredient lines checked off while cooking [recipeId]. Kept while
  /// the app runs, like the cook's place.
  CheckedIngredientsProvider._({
    required CheckedIngredientsFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'checkedIngredientsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$checkedIngredientsHash();

  @override
  String toString() {
    return r'checkedIngredientsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CheckedIngredients create() => CheckedIngredients();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<IngredientLineId> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<IngredientLineId>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CheckedIngredientsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$checkedIngredientsHash() =>
    r'4db4eedbc08278022e505852615848d89c422e40';

/// The ingredient lines checked off while cooking [recipeId]. Kept while
/// the app runs, like the cook's place.

final class CheckedIngredientsFamily extends $Family
    with
        $ClassFamilyOverride<
          CheckedIngredients,
          Set<IngredientLineId>,
          Set<IngredientLineId>,
          Set<IngredientLineId>,
          RecipeId
        > {
  CheckedIngredientsFamily._()
    : super(
        retry: null,
        name: r'checkedIngredientsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The ingredient lines checked off while cooking [recipeId]. Kept while
  /// the app runs, like the cook's place.

  CheckedIngredientsProvider call(RecipeId recipeId) =>
      CheckedIngredientsProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'checkedIngredientsProvider';
}

/// The ingredient lines checked off while cooking [recipeId]. Kept while
/// the app runs, like the cook's place.

abstract class _$CheckedIngredients extends $Notifier<Set<IngredientLineId>> {
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

/// Whether [lineId] is checked off. Only that line's row rebuilds when it
/// changes.

@ProviderFor(isIngredientChecked)
final isIngredientCheckedProvider = IsIngredientCheckedFamily._();

/// Whether [lineId] is checked off. Only that line's row rebuilds when it
/// changes.

final class IsIngredientCheckedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether [lineId] is checked off. Only that line's row rebuilds when it
  /// changes.
  IsIngredientCheckedProvider._({
    required IsIngredientCheckedFamily super.from,
    required (RecipeId, IngredientLineId) super.argument,
  }) : super(
         retry: null,
         name: r'isIngredientCheckedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isIngredientCheckedHash();

  @override
  String toString() {
    return r'isIngredientCheckedProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as (RecipeId, IngredientLineId);
    return isIngredientChecked(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsIngredientCheckedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isIngredientCheckedHash() =>
    r'6a7ecdcc13fa97d2baf0634c67dee5eda744d623';

/// Whether [lineId] is checked off. Only that line's row rebuilds when it
/// changes.

final class IsIngredientCheckedFamily extends $Family
    with $FunctionalFamilyOverride<bool, (RecipeId, IngredientLineId)> {
  IsIngredientCheckedFamily._()
    : super(
        retry: null,
        name: r'isIngredientCheckedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether [lineId] is checked off. Only that line's row rebuilds when it
  /// changes.

  IsIngredientCheckedProvider call(
    RecipeId recipeId,
    IngredientLineId lineId,
  ) => IsIngredientCheckedProvider._(argument: (recipeId, lineId), from: this);

  @override
  String toString() => r'isIngredientCheckedProvider';
}
