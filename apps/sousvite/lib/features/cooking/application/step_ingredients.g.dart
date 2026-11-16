// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_ingredients.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The ingredient lines a step uses, in the order it mentions them, for
/// its checklist (DESIGN_SYSTEM.md §10.3). A line belongs to the step
/// where smart step text places its amount.

@ProviderFor(StepIngredientIds)
final stepIngredientIdsProvider = StepIngredientIdsFamily._();

/// The ingredient lines a step uses, in the order it mentions them, for
/// its checklist (DESIGN_SYSTEM.md §10.3). A line belongs to the step
/// where smart step text places its amount.
final class StepIngredientIdsProvider
    extends $NotifierProvider<StepIngredientIds, List<IngredientLineId>> {
  /// The ingredient lines a step uses, in the order it mentions them, for
  /// its checklist (DESIGN_SYSTEM.md §10.3). A line belongs to the step
  /// where smart step text places its amount.
  StepIngredientIdsProvider._({
    required StepIngredientIdsFamily super.from,
    required (RecipeId, RecipeStepId) super.argument,
  }) : super(
         retry: null,
         name: r'stepIngredientIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stepIngredientIdsHash();

  @override
  String toString() {
    return r'stepIngredientIdsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  StepIngredientIds create() => StepIngredientIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<IngredientLineId> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<IngredientLineId>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StepIngredientIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stepIngredientIdsHash() => r'6f4c238722e8e5e8d329a2280aeb645c2b59fd42';

/// The ingredient lines a step uses, in the order it mentions them, for
/// its checklist (DESIGN_SYSTEM.md §10.3). A line belongs to the step
/// where smart step text places its amount.

final class StepIngredientIdsFamily extends $Family
    with
        $ClassFamilyOverride<
          StepIngredientIds,
          List<IngredientLineId>,
          List<IngredientLineId>,
          List<IngredientLineId>,
          (RecipeId, RecipeStepId)
        > {
  StepIngredientIdsFamily._()
    : super(
        retry: null,
        name: r'stepIngredientIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The ingredient lines a step uses, in the order it mentions them, for
  /// its checklist (DESIGN_SYSTEM.md §10.3). A line belongs to the step
  /// where smart step text places its amount.

  StepIngredientIdsProvider call(RecipeId recipeId, RecipeStepId stepId) =>
      StepIngredientIdsProvider._(argument: (recipeId, stepId), from: this);

  @override
  String toString() => r'stepIngredientIdsProvider';
}

/// The ingredient lines a step uses, in the order it mentions them, for
/// its checklist (DESIGN_SYSTEM.md §10.3). A line belongs to the step
/// where smart step text places its amount.

abstract class _$StepIngredientIds extends $Notifier<List<IngredientLineId>> {
  late final _$args = ref.$arg as (RecipeId, RecipeStepId);
  RecipeId get recipeId => _$args.$1;
  RecipeStepId get stepId => _$args.$2;

  List<IngredientLineId> build(RecipeId recipeId, RecipeStepId stepId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<IngredientLineId>, List<IngredientLineId>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<IngredientLineId>, List<IngredientLineId>>,
              List<IngredientLineId>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
