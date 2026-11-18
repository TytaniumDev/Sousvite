// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measuring_plan.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Which of your cups and spoons measure one ingredient line's amount as
/// shown, such as ½ Tbsp for 1 ½ tsp (DESIGN_SYSTEM.md §10.3).
///
/// Null when there's nothing to add: the line has no amount or a range,
/// your tools can't measure it (a mass or a count), the amount is already
/// one of your tools (1 cup), or your tools haven't loaded yet.

@ProviderFor(LineMeasuringPlan)
final lineMeasuringPlanProvider = LineMeasuringPlanFamily._();

/// Which of your cups and spoons measure one ingredient line's amount as
/// shown, such as ½ Tbsp for 1 ½ tsp (DESIGN_SYSTEM.md §10.3).
///
/// Null when there's nothing to add: the line has no amount or a range,
/// your tools can't measure it (a mass or a count), the amount is already
/// one of your tools (1 cup), or your tools haven't loaded yet.
final class LineMeasuringPlanProvider
    extends $NotifierProvider<LineMeasuringPlan, List<ToolUse>?> {
  /// Which of your cups and spoons measure one ingredient line's amount as
  /// shown, such as ½ Tbsp for 1 ½ tsp (DESIGN_SYSTEM.md §10.3).
  ///
  /// Null when there's nothing to add: the line has no amount or a range,
  /// your tools can't measure it (a mass or a count), the amount is already
  /// one of your tools (1 cup), or your tools haven't loaded yet.
  LineMeasuringPlanProvider._({
    required LineMeasuringPlanFamily super.from,
    required (RecipeId, IngredientLineId) super.argument,
  }) : super(
         retry: null,
         name: r'lineMeasuringPlanProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lineMeasuringPlanHash();

  @override
  String toString() {
    return r'lineMeasuringPlanProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  LineMeasuringPlan create() => LineMeasuringPlan();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ToolUse>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ToolUse>?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LineMeasuringPlanProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lineMeasuringPlanHash() => r'8289fb8fdc0dd024c1d85865b9f90d11d2b4df8d';

/// Which of your cups and spoons measure one ingredient line's amount as
/// shown, such as ½ Tbsp for 1 ½ tsp (DESIGN_SYSTEM.md §10.3).
///
/// Null when there's nothing to add: the line has no amount or a range,
/// your tools can't measure it (a mass or a count), the amount is already
/// one of your tools (1 cup), or your tools haven't loaded yet.

final class LineMeasuringPlanFamily extends $Family
    with
        $ClassFamilyOverride<
          LineMeasuringPlan,
          List<ToolUse>?,
          List<ToolUse>?,
          List<ToolUse>?,
          (RecipeId, IngredientLineId)
        > {
  LineMeasuringPlanFamily._()
    : super(
        retry: null,
        name: r'lineMeasuringPlanProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Which of your cups and spoons measure one ingredient line's amount as
  /// shown, such as ½ Tbsp for 1 ½ tsp (DESIGN_SYSTEM.md §10.3).
  ///
  /// Null when there's nothing to add: the line has no amount or a range,
  /// your tools can't measure it (a mass or a count), the amount is already
  /// one of your tools (1 cup), or your tools haven't loaded yet.

  LineMeasuringPlanProvider call(RecipeId recipeId, IngredientLineId lineId) =>
      LineMeasuringPlanProvider._(argument: (recipeId, lineId), from: this);

  @override
  String toString() => r'lineMeasuringPlanProvider';
}

/// Which of your cups and spoons measure one ingredient line's amount as
/// shown, such as ½ Tbsp for 1 ½ tsp (DESIGN_SYSTEM.md §10.3).
///
/// Null when there's nothing to add: the line has no amount or a range,
/// your tools can't measure it (a mass or a count), the amount is already
/// one of your tools (1 cup), or your tools haven't loaded yet.

abstract class _$LineMeasuringPlan extends $Notifier<List<ToolUse>?> {
  late final _$args = ref.$arg as (RecipeId, IngredientLineId);
  RecipeId get recipeId => _$args.$1;
  IngredientLineId get lineId => _$args.$2;

  List<ToolUse>? build(RecipeId recipeId, IngredientLineId lineId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<ToolUse>?, List<ToolUse>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ToolUse>?, List<ToolUse>?>,
              List<ToolUse>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
