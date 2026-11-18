// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_parts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every step's words with its ingredient mentions found (smart step text,
/// ENGINEERING.md §13), by step. Each ingredient's amount goes at its
/// first mention in cooking order: loose steps, then each section.
///
/// Amounts are as written; screens show them with `shownAmount`, so steps
/// scale and convert exactly like the ingredient list. The recipe page and
/// cooking mode both read these.

@ProviderFor(smartStepParts)
final smartStepPartsProvider = SmartStepPartsFamily._();

/// Every step's words with its ingredient mentions found (smart step text,
/// ENGINEERING.md §13), by step. Each ingredient's amount goes at its
/// first mention in cooking order: loose steps, then each section.
///
/// Amounts are as written; screens show them with `shownAmount`, so steps
/// scale and convert exactly like the ingredient list. The recipe page and
/// cooking mode both read these.

final class SmartStepPartsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<RecipeStepId, List<StepPart>>>,
          AsyncValue<Map<RecipeStepId, List<StepPart>>>,
          AsyncValue<Map<RecipeStepId, List<StepPart>>>
        >
    with $Provider<AsyncValue<Map<RecipeStepId, List<StepPart>>>> {
  /// Every step's words with its ingredient mentions found (smart step text,
  /// ENGINEERING.md §13), by step. Each ingredient's amount goes at its
  /// first mention in cooking order: loose steps, then each section.
  ///
  /// Amounts are as written; screens show them with `shownAmount`, so steps
  /// scale and convert exactly like the ingredient list. The recipe page and
  /// cooking mode both read these.
  SmartStepPartsProvider._({
    required SmartStepPartsFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'smartStepPartsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$smartStepPartsHash();

  @override
  String toString() {
    return r'smartStepPartsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<Map<RecipeStepId, List<StepPart>>>>
  $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  AsyncValue<Map<RecipeStepId, List<StepPart>>> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return smartStepParts(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    AsyncValue<Map<RecipeStepId, List<StepPart>>> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<Map<RecipeStepId, List<StepPart>>>>(
            value,
          ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SmartStepPartsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$smartStepPartsHash() => r'f0bdaaaf54ede123d306c6d0384fb2e1628947e0';

/// Every step's words with its ingredient mentions found (smart step text,
/// ENGINEERING.md §13), by step. Each ingredient's amount goes at its
/// first mention in cooking order: loose steps, then each section.
///
/// Amounts are as written; screens show them with `shownAmount`, so steps
/// scale and convert exactly like the ingredient list. The recipe page and
/// cooking mode both read these.

final class SmartStepPartsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<Map<RecipeStepId, List<StepPart>>>,
          RecipeId
        > {
  SmartStepPartsFamily._()
    : super(
        retry: null,
        name: r'smartStepPartsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every step's words with its ingredient mentions found (smart step text,
  /// ENGINEERING.md §13), by step. Each ingredient's amount goes at its
  /// first mention in cooking order: loose steps, then each section.
  ///
  /// Amounts are as written; screens show them with `shownAmount`, so steps
  /// scale and convert exactly like the ingredient list. The recipe page and
  /// cooking mode both read these.

  SmartStepPartsProvider call(RecipeId recipeId) =>
      SmartStepPartsProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'smartStepPartsProvider';
}

/// One step's parts. Notifies only when this step's parts change.

@ProviderFor(StepParts)
final stepPartsProvider = StepPartsFamily._();

/// One step's parts. Notifies only when this step's parts change.
final class StepPartsProvider
    extends $NotifierProvider<StepParts, List<StepPart>> {
  /// One step's parts. Notifies only when this step's parts change.
  StepPartsProvider._({
    required StepPartsFamily super.from,
    required (RecipeId, RecipeStepId) super.argument,
  }) : super(
         retry: null,
         name: r'stepPartsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stepPartsHash();

  @override
  String toString() {
    return r'stepPartsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  StepParts create() => StepParts();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<StepPart> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<StepPart>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StepPartsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stepPartsHash() => r'e5156e2affe7a9872cb10a32cd66205a61a0715a';

/// One step's parts. Notifies only when this step's parts change.

final class StepPartsFamily extends $Family
    with
        $ClassFamilyOverride<
          StepParts,
          List<StepPart>,
          List<StepPart>,
          List<StepPart>,
          (RecipeId, RecipeStepId)
        > {
  StepPartsFamily._()
    : super(
        retry: null,
        name: r'stepPartsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One step's parts. Notifies only when this step's parts change.

  StepPartsProvider call(RecipeId recipeId, RecipeStepId stepId) =>
      StepPartsProvider._(argument: (recipeId, stepId), from: this);

  @override
  String toString() => r'stepPartsProvider';
}

/// One step's parts. Notifies only when this step's parts change.

abstract class _$StepParts extends $Notifier<List<StepPart>> {
  late final _$args = ref.$arg as (RecipeId, RecipeStepId);
  RecipeId get recipeId => _$args.$1;
  RecipeStepId get stepId => _$args.$2;

  List<StepPart> build(RecipeId recipeId, RecipeStepId stepId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<StepPart>, List<StepPart>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<StepPart>, List<StepPart>>,
              List<StepPart>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
