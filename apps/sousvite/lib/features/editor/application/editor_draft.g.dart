// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_draft.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The recipe being edited. Changes stay in this draft until [save]
/// writes them in one transaction; leaving without saving drops them.
///
/// A recipe id that isn't saved yet opens a new recipe, with a "Prep"
/// step section to start (DESIGN_SYSTEM.md §10.2).

@ProviderFor(EditorDraft)
final editorDraftProvider = EditorDraftFamily._();

/// The recipe being edited. Changes stay in this draft until [save]
/// writes them in one transaction; leaving without saving drops them.
///
/// A recipe id that isn't saved yet opens a new recipe, with a "Prep"
/// step section to start (DESIGN_SYSTEM.md §10.2).
final class EditorDraftProvider
    extends $AsyncNotifierProvider<EditorDraft, EditorState> {
  /// The recipe being edited. Changes stay in this draft until [save]
  /// writes them in one transaction; leaving without saving drops them.
  ///
  /// A recipe id that isn't saved yet opens a new recipe, with a "Prep"
  /// step section to start (DESIGN_SYSTEM.md §10.2).
  EditorDraftProvider._({
    required EditorDraftFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'editorDraftProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editorDraftHash();

  @override
  String toString() {
    return r'editorDraftProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditorDraft create() => EditorDraft();

  @override
  bool operator ==(Object other) {
    return other is EditorDraftProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editorDraftHash() => r'98ee67eb4d1cbc0b43b73b2d869cc87ba3feb34c';

/// The recipe being edited. Changes stay in this draft until [save]
/// writes them in one transaction; leaving without saving drops them.
///
/// A recipe id that isn't saved yet opens a new recipe, with a "Prep"
/// step section to start (DESIGN_SYSTEM.md §10.2).

final class EditorDraftFamily extends $Family
    with
        $ClassFamilyOverride<
          EditorDraft,
          AsyncValue<EditorState>,
          EditorState,
          FutureOr<EditorState>,
          RecipeId
        > {
  EditorDraftFamily._()
    : super(
        retry: null,
        name: r'editorDraftProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The recipe being edited. Changes stay in this draft until [save]
  /// writes them in one transaction; leaving without saving drops them.
  ///
  /// A recipe id that isn't saved yet opens a new recipe, with a "Prep"
  /// step section to start (DESIGN_SYSTEM.md §10.2).

  EditorDraftProvider call(RecipeId recipeId) =>
      EditorDraftProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'editorDraftProvider';
}

/// The recipe being edited. Changes stay in this draft until [save]
/// writes them in one transaction; leaving without saving drops them.
///
/// A recipe id that isn't saved yet opens a new recipe, with a "Prep"
/// step section to start (DESIGN_SYSTEM.md §10.2).

abstract class _$EditorDraft extends $AsyncNotifier<EditorState> {
  late final _$args = ref.$arg as RecipeId;
  RecipeId get recipeId => _$args;

  FutureOr<EditorState> build(RecipeId recipeId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EditorState>, EditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EditorState>, EditorState>,
              AsyncValue<EditorState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Whether the draft differs from what is saved. A new recipe counts as
/// changed once it has a name.

@ProviderFor(editorHasChanges)
final editorHasChangesProvider = EditorHasChangesFamily._();

/// Whether the draft differs from what is saved. A new recipe counts as
/// changed once it has a name.

final class EditorHasChangesProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the draft differs from what is saved. A new recipe counts as
  /// changed once it has a name.
  EditorHasChangesProvider._({
    required EditorHasChangesFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'editorHasChangesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editorHasChangesHash();

  @override
  String toString() {
    return r'editorHasChangesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as RecipeId;
    return editorHasChanges(ref, argument);
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
    return other is EditorHasChangesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editorHasChangesHash() => r'0fbb42e61d1fe4395b8bc8af4c2d964522248bc4';

/// Whether the draft differs from what is saved. A new recipe counts as
/// changed once it has a name.

final class EditorHasChangesFamily extends $Family
    with $FunctionalFamilyOverride<bool, RecipeId> {
  EditorHasChangesFamily._()
    : super(
        retry: null,
        name: r'editorHasChangesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the draft differs from what is saved. A new recipe counts as
  /// changed once it has a name.

  EditorHasChangesProvider call(RecipeId recipeId) =>
      EditorHasChangesProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'editorHasChangesProvider';
}

/// Whether the recipe has never been saved.

@ProviderFor(editorIsNew)
final editorIsNewProvider = EditorIsNewFamily._();

/// Whether the recipe has never been saved.

final class EditorIsNewProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the recipe has never been saved.
  EditorIsNewProvider._({
    required EditorIsNewFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'editorIsNewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editorIsNewHash();

  @override
  String toString() {
    return r'editorIsNewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as RecipeId;
    return editorIsNew(ref, argument);
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
    return other is EditorIsNewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editorIsNewHash() => r'e7ce6bd33674f60630a6d0c42946e73283349ea7';

/// Whether the recipe has never been saved.

final class EditorIsNewFamily extends $Family
    with $FunctionalFamilyOverride<bool, RecipeId> {
  EditorIsNewFamily._()
    : super(
        retry: null,
        name: r'editorIsNewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the recipe has never been saved.

  EditorIsNewProvider call(RecipeId recipeId) =>
      EditorIsNewProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'editorIsNewProvider';
}
