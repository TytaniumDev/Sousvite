// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_outline.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The draft's ingredient sections, in order.

@ProviderFor(EditorIngredientSectionIds)
final editorIngredientSectionIdsProvider = EditorIngredientSectionIdsFamily._();

/// The draft's ingredient sections, in order.
final class EditorIngredientSectionIdsProvider
    extends
        $NotifierProvider<
          EditorIngredientSectionIds,
          List<IngredientSectionId>
        > {
  /// The draft's ingredient sections, in order.
  EditorIngredientSectionIdsProvider._({
    required EditorIngredientSectionIdsFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'editorIngredientSectionIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editorIngredientSectionIdsHash();

  @override
  String toString() {
    return r'editorIngredientSectionIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditorIngredientSectionIds create() => EditorIngredientSectionIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<IngredientSectionId> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<IngredientSectionId>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EditorIngredientSectionIdsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editorIngredientSectionIdsHash() =>
    r'3d2f33791e48f02658638721e1d42f558392a664';

/// The draft's ingredient sections, in order.

final class EditorIngredientSectionIdsFamily extends $Family
    with
        $ClassFamilyOverride<
          EditorIngredientSectionIds,
          List<IngredientSectionId>,
          List<IngredientSectionId>,
          List<IngredientSectionId>,
          RecipeId
        > {
  EditorIngredientSectionIdsFamily._()
    : super(
        retry: null,
        name: r'editorIngredientSectionIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The draft's ingredient sections, in order.

  EditorIngredientSectionIdsProvider call(RecipeId recipeId) =>
      EditorIngredientSectionIdsProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'editorIngredientSectionIdsProvider';
}

/// The draft's ingredient sections, in order.

abstract class _$EditorIngredientSectionIds
    extends $Notifier<List<IngredientSectionId>> {
  late final _$args = ref.$arg as RecipeId;
  RecipeId get recipeId => _$args;

  List<IngredientSectionId> build(RecipeId recipeId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<IngredientSectionId>, List<IngredientSectionId>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<IngredientSectionId>, List<IngredientSectionId>>,
              List<IngredientSectionId>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The draft's ingredient lines in [sectionId], or the loose lines when
/// it is null.

@ProviderFor(EditorLineIds)
final editorLineIdsProvider = EditorLineIdsFamily._();

/// The draft's ingredient lines in [sectionId], or the loose lines when
/// it is null.
final class EditorLineIdsProvider
    extends $NotifierProvider<EditorLineIds, List<IngredientLineId>> {
  /// The draft's ingredient lines in [sectionId], or the loose lines when
  /// it is null.
  EditorLineIdsProvider._({
    required EditorLineIdsFamily super.from,
    required (RecipeId, IngredientSectionId?) super.argument,
  }) : super(
         retry: null,
         name: r'editorLineIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editorLineIdsHash();

  @override
  String toString() {
    return r'editorLineIdsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  EditorLineIds create() => EditorLineIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<IngredientLineId> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<IngredientLineId>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EditorLineIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editorLineIdsHash() => r'0bb1de87c1ea1cdb1abff6e600b78c75bb365f47';

/// The draft's ingredient lines in [sectionId], or the loose lines when
/// it is null.

final class EditorLineIdsFamily extends $Family
    with
        $ClassFamilyOverride<
          EditorLineIds,
          List<IngredientLineId>,
          List<IngredientLineId>,
          List<IngredientLineId>,
          (RecipeId, IngredientSectionId?)
        > {
  EditorLineIdsFamily._()
    : super(
        retry: null,
        name: r'editorLineIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The draft's ingredient lines in [sectionId], or the loose lines when
  /// it is null.

  EditorLineIdsProvider call(
    RecipeId recipeId,
    IngredientSectionId? sectionId,
  ) => EditorLineIdsProvider._(argument: (recipeId, sectionId), from: this);

  @override
  String toString() => r'editorLineIdsProvider';
}

/// The draft's ingredient lines in [sectionId], or the loose lines when
/// it is null.

abstract class _$EditorLineIds extends $Notifier<List<IngredientLineId>> {
  late final _$args = ref.$arg as (RecipeId, IngredientSectionId?);
  RecipeId get recipeId => _$args.$1;
  IngredientSectionId? get sectionId => _$args.$2;

  List<IngredientLineId> build(
    RecipeId recipeId,
    IngredientSectionId? sectionId,
  );
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

/// The draft's step sections, in order.

@ProviderFor(EditorStepSectionIds)
final editorStepSectionIdsProvider = EditorStepSectionIdsFamily._();

/// The draft's step sections, in order.
final class EditorStepSectionIdsProvider
    extends $NotifierProvider<EditorStepSectionIds, List<StepSectionId>> {
  /// The draft's step sections, in order.
  EditorStepSectionIdsProvider._({
    required EditorStepSectionIdsFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'editorStepSectionIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editorStepSectionIdsHash();

  @override
  String toString() {
    return r'editorStepSectionIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditorStepSectionIds create() => EditorStepSectionIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<StepSectionId> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<StepSectionId>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EditorStepSectionIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editorStepSectionIdsHash() =>
    r'8c4d13d49a00e9790c2fa8a3317bc1cb8d73e6cd';

/// The draft's step sections, in order.

final class EditorStepSectionIdsFamily extends $Family
    with
        $ClassFamilyOverride<
          EditorStepSectionIds,
          List<StepSectionId>,
          List<StepSectionId>,
          List<StepSectionId>,
          RecipeId
        > {
  EditorStepSectionIdsFamily._()
    : super(
        retry: null,
        name: r'editorStepSectionIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The draft's step sections, in order.

  EditorStepSectionIdsProvider call(RecipeId recipeId) =>
      EditorStepSectionIdsProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'editorStepSectionIdsProvider';
}

/// The draft's step sections, in order.

abstract class _$EditorStepSectionIds extends $Notifier<List<StepSectionId>> {
  late final _$args = ref.$arg as RecipeId;
  RecipeId get recipeId => _$args;

  List<StepSectionId> build(RecipeId recipeId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<StepSectionId>, List<StepSectionId>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<StepSectionId>, List<StepSectionId>>,
              List<StepSectionId>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The draft's steps in [sectionId], or the loose steps when it is null.

@ProviderFor(EditorStepIds)
final editorStepIdsProvider = EditorStepIdsFamily._();

/// The draft's steps in [sectionId], or the loose steps when it is null.
final class EditorStepIdsProvider
    extends $NotifierProvider<EditorStepIds, List<RecipeStepId>> {
  /// The draft's steps in [sectionId], or the loose steps when it is null.
  EditorStepIdsProvider._({
    required EditorStepIdsFamily super.from,
    required (RecipeId, StepSectionId?) super.argument,
  }) : super(
         retry: null,
         name: r'editorStepIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editorStepIdsHash();

  @override
  String toString() {
    return r'editorStepIdsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  EditorStepIds create() => EditorStepIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<RecipeStepId> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<RecipeStepId>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EditorStepIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editorStepIdsHash() => r'd54acbbbf9146741b8fb1fc2a64b54d696b6e048';

/// The draft's steps in [sectionId], or the loose steps when it is null.

final class EditorStepIdsFamily extends $Family
    with
        $ClassFamilyOverride<
          EditorStepIds,
          List<RecipeStepId>,
          List<RecipeStepId>,
          List<RecipeStepId>,
          (RecipeId, StepSectionId?)
        > {
  EditorStepIdsFamily._()
    : super(
        retry: null,
        name: r'editorStepIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The draft's steps in [sectionId], or the loose steps when it is null.

  EditorStepIdsProvider call(RecipeId recipeId, StepSectionId? sectionId) =>
      EditorStepIdsProvider._(argument: (recipeId, sectionId), from: this);

  @override
  String toString() => r'editorStepIdsProvider';
}

/// The draft's steps in [sectionId], or the loose steps when it is null.

abstract class _$EditorStepIds extends $Notifier<List<RecipeStepId>> {
  late final _$args = ref.$arg as (RecipeId, StepSectionId?);
  RecipeId get recipeId => _$args.$1;
  StepSectionId? get sectionId => _$args.$2;

  List<RecipeStepId> build(RecipeId recipeId, StepSectionId? sectionId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<RecipeStepId>, List<RecipeStepId>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<RecipeStepId>, List<RecipeStepId>>,
              List<RecipeStepId>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

/// The product a draft line was scanned from in this edit, or null.

@ProviderFor(editorScannedProduct)
final editorScannedProductProvider = EditorScannedProductFamily._();

/// The product a draft line was scanned from in this edit, or null.

final class EditorScannedProductProvider
    extends
        $FunctionalProvider<ScannedProduct?, ScannedProduct?, ScannedProduct?>
    with $Provider<ScannedProduct?> {
  /// The product a draft line was scanned from in this edit, or null.
  EditorScannedProductProvider._({
    required EditorScannedProductFamily super.from,
    required (RecipeId, IngredientLineId) super.argument,
  }) : super(
         retry: null,
         name: r'editorScannedProductProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editorScannedProductHash();

  @override
  String toString() {
    return r'editorScannedProductProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<ScannedProduct?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ScannedProduct? create(Ref ref) {
    final argument = this.argument as (RecipeId, IngredientLineId);
    return editorScannedProduct(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScannedProduct? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScannedProduct?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EditorScannedProductProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editorScannedProductHash() =>
    r'a7646f52ddf9476373fc0bfd76df899cf5b572df';

/// The product a draft line was scanned from in this edit, or null.

final class EditorScannedProductFamily extends $Family
    with
        $FunctionalFamilyOverride<
          ScannedProduct?,
          (RecipeId, IngredientLineId)
        > {
  EditorScannedProductFamily._()
    : super(
        retry: null,
        name: r'editorScannedProductProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The product a draft line was scanned from in this edit, or null.

  EditorScannedProductProvider call(
    RecipeId recipeId,
    IngredientLineId lineId,
  ) => EditorScannedProductProvider._(argument: (recipeId, lineId), from: this);

  @override
  String toString() => r'editorScannedProductProvider';
}

/// One draft line, or null once it is removed.

@ProviderFor(editorLine)
final editorLineProvider = EditorLineFamily._();

/// One draft line, or null once it is removed.

final class EditorLineProvider
    extends
        $FunctionalProvider<IngredientLine?, IngredientLine?, IngredientLine?>
    with $Provider<IngredientLine?> {
  /// One draft line, or null once it is removed.
  EditorLineProvider._({
    required EditorLineFamily super.from,
    required (RecipeId, IngredientLineId) super.argument,
  }) : super(
         retry: null,
         name: r'editorLineProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editorLineHash();

  @override
  String toString() {
    return r'editorLineProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<IngredientLine?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IngredientLine? create(Ref ref) {
    final argument = this.argument as (RecipeId, IngredientLineId);
    return editorLine(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IngredientLine? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IngredientLine?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EditorLineProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editorLineHash() => r'774db5911caa08e54352980c5762600f46cdd9a6';

/// One draft line, or null once it is removed.

final class EditorLineFamily extends $Family
    with
        $FunctionalFamilyOverride<
          IngredientLine?,
          (RecipeId, IngredientLineId)
        > {
  EditorLineFamily._()
    : super(
        retry: null,
        name: r'editorLineProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One draft line, or null once it is removed.

  EditorLineProvider call(RecipeId recipeId, IngredientLineId lineId) =>
      EditorLineProvider._(argument: (recipeId, lineId), from: this);

  @override
  String toString() => r'editorLineProvider';
}
