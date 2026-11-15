// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_filter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The folder the library shows, or null for every recipe.

@ProviderFor(LibraryFolder)
final libraryFolderProvider = LibraryFolderProvider._();

/// The folder the library shows, or null for every recipe.
final class LibraryFolderProvider
    extends $NotifierProvider<LibraryFolder, FolderId?> {
  /// The folder the library shows, or null for every recipe.
  LibraryFolderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryFolderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryFolderHash();

  @$internal
  @override
  LibraryFolder create() => LibraryFolder();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FolderId? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FolderId?>(value),
    );
  }
}

String _$libraryFolderHash() => r'7fa3cf964d50d30a156cb452cdcbb954e36a9fb7';

/// The folder the library shows, or null for every recipe.

abstract class _$LibraryFolder extends $Notifier<FolderId?> {
  FolderId? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FolderId?, FolderId?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FolderId?, FolderId?>,
              FolderId?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// What the user typed into the library's search field.

@ProviderFor(LibraryQuery)
final libraryQueryProvider = LibraryQueryProvider._();

/// What the user typed into the library's search field.
final class LibraryQueryProvider
    extends $NotifierProvider<LibraryQuery, String> {
  /// What the user typed into the library's search field.
  LibraryQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryQueryHash();

  @$internal
  @override
  LibraryQuery create() => LibraryQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$libraryQueryHash() => r'68667dbd5bdd5f2d1436b5fadeb63c7800f3fa16';

/// What the user typed into the library's search field.

abstract class _$LibraryQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
