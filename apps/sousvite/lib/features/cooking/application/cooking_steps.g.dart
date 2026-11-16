// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_steps.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every step of [recipeId] in the order it is cooked: loose steps, then
/// each section in order (DESIGN_SYSTEM.md §10.3).

@ProviderFor(cookingSteps)
final cookingStepsProvider = CookingStepsFamily._();

/// Every step of [recipeId] in the order it is cooked: loose steps, then
/// each section in order (DESIGN_SYSTEM.md §10.3).

final class CookingStepsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CookingStep>>,
          AsyncValue<List<CookingStep>>,
          AsyncValue<List<CookingStep>>
        >
    with $Provider<AsyncValue<List<CookingStep>>> {
  /// Every step of [recipeId] in the order it is cooked: loose steps, then
  /// each section in order (DESIGN_SYSTEM.md §10.3).
  CookingStepsProvider._({
    required CookingStepsFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'cookingStepsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cookingStepsHash();

  @override
  String toString() {
    return r'cookingStepsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<CookingStep>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<CookingStep>> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return cookingSteps(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<CookingStep>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<CookingStep>>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CookingStepsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cookingStepsHash() => r'd476d149877ac29b2b4b36661f5f6856f895e55a';

/// Every step of [recipeId] in the order it is cooked: loose steps, then
/// each section in order (DESIGN_SYSTEM.md §10.3).

final class CookingStepsFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<List<CookingStep>>, RecipeId> {
  CookingStepsFamily._()
    : super(
        retry: null,
        name: r'cookingStepsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every step of [recipeId] in the order it is cooked: loose steps, then
  /// each section in order (DESIGN_SYSTEM.md §10.3).

  CookingStepsProvider call(RecipeId recipeId) =>
      CookingStepsProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'cookingStepsProvider';
}

/// Which step is showing. Kept while the app runs, so leaving cooking mode
/// and coming back keeps your place (DESIGN_SYSTEM.md §10.3).

@ProviderFor(CookingPosition)
final cookingPositionProvider = CookingPositionFamily._();

/// Which step is showing. Kept while the app runs, so leaving cooking mode
/// and coming back keeps your place (DESIGN_SYSTEM.md §10.3).
final class CookingPositionProvider
    extends $NotifierProvider<CookingPosition, int> {
  /// Which step is showing. Kept while the app runs, so leaving cooking mode
  /// and coming back keeps your place (DESIGN_SYSTEM.md §10.3).
  CookingPositionProvider._({
    required CookingPositionFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'cookingPositionProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cookingPositionHash();

  @override
  String toString() {
    return r'cookingPositionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CookingPosition create() => CookingPosition();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CookingPositionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cookingPositionHash() => r'af0fdefe688f703d6c65371cc2aecfb0245d28f7';

/// Which step is showing. Kept while the app runs, so leaving cooking mode
/// and coming back keeps your place (DESIGN_SYSTEM.md §10.3).

final class CookingPositionFamily extends $Family
    with $ClassFamilyOverride<CookingPosition, int, int, int, RecipeId> {
  CookingPositionFamily._()
    : super(
        retry: null,
        name: r'cookingPositionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Which step is showing. Kept while the app runs, so leaving cooking mode
  /// and coming back keeps your place (DESIGN_SYSTEM.md §10.3).

  CookingPositionProvider call(RecipeId recipeId) =>
      CookingPositionProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'cookingPositionProvider';
}

/// Which step is showing. Kept while the app runs, so leaving cooking mode
/// and coming back keeps your place (DESIGN_SYSTEM.md §10.3).

abstract class _$CookingPosition extends $Notifier<int> {
  late final _$args = ref.$arg as RecipeId;
  RecipeId get recipeId => _$args;

  int build(RecipeId recipeId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The progress shown in the header, or null before the steps load or
/// when there are none. The position is clamped to the steps there are.

@ProviderFor(cookingProgress)
final cookingProgressProvider = CookingProgressFamily._();

/// The progress shown in the header, or null before the steps load or
/// when there are none. The position is clamped to the steps there are.

final class CookingProgressProvider
    extends
        $FunctionalProvider<
          CookingProgress?,
          CookingProgress?,
          CookingProgress?
        >
    with $Provider<CookingProgress?> {
  /// The progress shown in the header, or null before the steps load or
  /// when there are none. The position is clamped to the steps there are.
  CookingProgressProvider._({
    required CookingProgressFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'cookingProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cookingProgressHash();

  @override
  String toString() {
    return r'cookingProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<CookingProgress?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CookingProgress? create(Ref ref) {
    final argument = this.argument as RecipeId;
    return cookingProgress(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CookingProgress? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CookingProgress?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CookingProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cookingProgressHash() => r'902cf6bb3240244aa1029d2fbb63f4352175acf0';

/// The progress shown in the header, or null before the steps load or
/// when there are none. The position is clamped to the steps there are.

final class CookingProgressFamily extends $Family
    with $FunctionalFamilyOverride<CookingProgress?, RecipeId> {
  CookingProgressFamily._()
    : super(
        retry: null,
        name: r'cookingProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The progress shown in the header, or null before the steps load or
  /// when there are none. The position is clamped to the steps there are.

  CookingProgressProvider call(RecipeId recipeId) =>
      CookingProgressProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'cookingProgressProvider';
}
