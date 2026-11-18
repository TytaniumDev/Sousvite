// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_filter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the user typed into the search field of the page showing [scope].
/// Each page keeps its own search.

@ProviderFor(LibraryQuery)
final libraryQueryProvider = LibraryQueryFamily._();

/// What the user typed into the search field of the page showing [scope].
/// Each page keeps its own search.
final class LibraryQueryProvider
    extends $NotifierProvider<LibraryQuery, String> {
  /// What the user typed into the search field of the page showing [scope].
  /// Each page keeps its own search.
  LibraryQueryProvider._({
    required LibraryQueryFamily super.from,
    required LibraryScope super.argument,
  }) : super(
         retry: null,
         name: r'libraryQueryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$libraryQueryHash();

  @override
  String toString() {
    return r'libraryQueryProvider'
        ''
        '($argument)';
  }

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

  @override
  bool operator ==(Object other) {
    return other is LibraryQueryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$libraryQueryHash() => r'35a0d9c4f9bca9f37fc9f60fc13de8d7d599202a';

/// What the user typed into the search field of the page showing [scope].
/// Each page keeps its own search.

final class LibraryQueryFamily extends $Family
    with
        $ClassFamilyOverride<
          LibraryQuery,
          String,
          String,
          String,
          LibraryScope
        > {
  LibraryQueryFamily._()
    : super(
        retry: null,
        name: r'libraryQueryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the user typed into the search field of the page showing [scope].
  /// Each page keeps its own search.

  LibraryQueryProvider call(LibraryScope scope) =>
      LibraryQueryProvider._(argument: scope, from: this);

  @override
  String toString() => r'libraryQueryProvider';
}

/// What the user typed into the search field of the page showing [scope].
/// Each page keeps its own search.

abstract class _$LibraryQuery extends $Notifier<String> {
  late final _$args = ref.$arg as LibraryScope;
  LibraryScope get scope => _$args;

  String build(LibraryScope scope);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Whether the search field of the page showing [scope] has words in it.

@ProviderFor(isSearching)
final isSearchingProvider = IsSearchingFamily._();

/// Whether the search field of the page showing [scope] has words in it.

final class IsSearchingProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the search field of the page showing [scope] has words in it.
  IsSearchingProvider._({
    required IsSearchingFamily super.from,
    required LibraryScope super.argument,
  }) : super(
         retry: null,
         name: r'isSearchingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isSearchingHash();

  @override
  String toString() {
    return r'isSearchingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as LibraryScope;
    return isSearching(ref, argument);
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
    return other is IsSearchingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isSearchingHash() => r'cbc6fcd7ad01ee9709ee4bf196115f1d2a2af920';

/// Whether the search field of the page showing [scope] has words in it.

final class IsSearchingFamily extends $Family
    with $FunctionalFamilyOverride<bool, LibraryScope> {
  IsSearchingFamily._()
    : super(
        retry: null,
        name: r'isSearchingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the search field of the page showing [scope] has words in it.

  IsSearchingProvider call(LibraryScope scope) =>
      IsSearchingProvider._(argument: scope, from: this);

  @override
  String toString() => r'isSearchingProvider';
}
