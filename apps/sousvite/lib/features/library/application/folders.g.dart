// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folders.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every folder, in the repository's order.

@ProviderFor(folders)
final foldersProvider = FoldersProvider._();

/// Every folder, in the repository's order.

final class FoldersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Folder>>,
          List<Folder>,
          Stream<List<Folder>>
        >
    with $FutureModifier<List<Folder>>, $StreamProvider<List<Folder>> {
  /// Every folder, in the repository's order.
  FoldersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foldersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foldersHash();

  @$internal
  @override
  $StreamProviderElement<List<Folder>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Folder>> create(Ref ref) {
    return folders(ref);
  }
}

String _$foldersHash() => r'0c51c5d69c9ec3612721337150f498290d3cad98';

/// The folder ids, in order. Null while loading.
///
/// Notifies only when folders are added, removed, or reordered, not when
/// one is renamed, so the folder grid doesn't rebuild for a new name.

@ProviderFor(FolderIds)
final folderIdsProvider = FolderIdsProvider._();

/// The folder ids, in order. Null while loading.
///
/// Notifies only when folders are added, removed, or reordered, not when
/// one is renamed, so the folder grid doesn't rebuild for a new name.
final class FolderIdsProvider
    extends $NotifierProvider<FolderIds, List<FolderId>?> {
  /// The folder ids, in order. Null while loading.
  ///
  /// Notifies only when folders are added, removed, or reordered, not when
  /// one is renamed, so the folder grid doesn't rebuild for a new name.
  FolderIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderIdsHash();

  @$internal
  @override
  FolderIds create() => FolderIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<FolderId>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<FolderId>?>(value),
    );
  }
}

String _$folderIdsHash() => r'e8d29986b7f6caf32e5ac32b840f53de82a07279';

/// The folder ids, in order. Null while loading.
///
/// Notifies only when folders are added, removed, or reordered, not when
/// one is renamed, so the folder grid doesn't rebuild for a new name.

abstract class _$FolderIds extends $Notifier<List<FolderId>?> {
  List<FolderId>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<FolderId>?, List<FolderId>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<FolderId>?, List<FolderId>?>,
              List<FolderId>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// One folder's name. Notifies only when that name changes.

@ProviderFor(folderName)
final folderNameProvider = FolderNameFamily._();

/// One folder's name. Notifies only when that name changes.

final class FolderNameProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// One folder's name. Notifies only when that name changes.
  FolderNameProvider._({
    required FolderNameFamily super.from,
    required FolderId super.argument,
  }) : super(
         retry: null,
         name: r'folderNameProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$folderNameHash();

  @override
  String toString() {
    return r'folderNameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    final argument = this.argument as FolderId;
    return folderName(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FolderNameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$folderNameHash() => r'4d2f80ae8a08984316881a2904b2ec32f934a2a1';

/// One folder's name. Notifies only when that name changes.

final class FolderNameFamily extends $Family
    with $FunctionalFamilyOverride<String?, FolderId> {
  FolderNameFamily._()
    : super(
        retry: null,
        name: r'folderNameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One folder's name. Notifies only when that name changes.

  FolderNameProvider call(FolderId folderId) =>
      FolderNameProvider._(argument: folderId, from: this);

  @override
  String toString() => r'folderNameProvider';
}

/// Whether one recipe is in one folder. Null while loading.

@ProviderFor(isRecipeInFolder)
final isRecipeInFolderProvider = IsRecipeInFolderFamily._();

/// Whether one recipe is in one folder. Null while loading.

final class IsRecipeInFolderProvider
    extends $FunctionalProvider<bool?, bool?, bool?>
    with $Provider<bool?> {
  /// Whether one recipe is in one folder. Null while loading.
  IsRecipeInFolderProvider._({
    required IsRecipeInFolderFamily super.from,
    required (FolderId, RecipeId) super.argument,
  }) : super(
         retry: null,
         name: r'isRecipeInFolderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isRecipeInFolderHash();

  @override
  String toString() {
    return r'isRecipeInFolderProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<bool?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool? create(Ref ref) {
    final argument = this.argument as (FolderId, RecipeId);
    return isRecipeInFolder(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsRecipeInFolderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isRecipeInFolderHash() => r'c3269f433d761353903c399b8dfbf79eb0e5b06d';

/// Whether one recipe is in one folder. Null while loading.

final class IsRecipeInFolderFamily extends $Family
    with $FunctionalFamilyOverride<bool?, (FolderId, RecipeId)> {
  IsRecipeInFolderFamily._()
    : super(
        retry: null,
        name: r'isRecipeInFolderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether one recipe is in one folder. Null while loading.

  IsRecipeInFolderProvider call(FolderId folderId, RecipeId recipeId) =>
      IsRecipeInFolderProvider._(argument: (folderId, recipeId), from: this);

  @override
  String toString() => r'isRecipeInFolderProvider';
}

/// Creates, renames, and deletes folders, and moves recipes in and out
/// of them. A recipe can be in several folders (PRD 7.1).

@ProviderFor(FolderEditor)
final folderEditorProvider = FolderEditorProvider._();

/// Creates, renames, and deletes folders, and moves recipes in and out
/// of them. A recipe can be in several folders (PRD 7.1).
final class FolderEditorProvider extends $NotifierProvider<FolderEditor, void> {
  /// Creates, renames, and deletes folders, and moves recipes in and out
  /// of them. A recipe can be in several folders (PRD 7.1).
  FolderEditorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderEditorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderEditorHash();

  @$internal
  @override
  FolderEditor create() => FolderEditor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$folderEditorHash() => r'b756160c20b0895b1bd89c70a661f484f1c50579';

/// Creates, renames, and deletes folders, and moves recipes in and out
/// of them. A recipe can be in several folders (PRD 7.1).

abstract class _$FolderEditor extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
