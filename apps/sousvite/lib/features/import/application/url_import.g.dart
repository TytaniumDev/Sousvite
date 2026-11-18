// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_import.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Imports a recipe from a web address. The state is the imported
/// recipe's id once saved, null before anything is imported, or an
/// [ImportFailure].

@ProviderFor(UrlImport)
final urlImportProvider = UrlImportProvider._();

/// Imports a recipe from a web address. The state is the imported
/// recipe's id once saved, null before anything is imported, or an
/// [ImportFailure].
final class UrlImportProvider
    extends $AsyncNotifierProvider<UrlImport, RecipeId?> {
  /// Imports a recipe from a web address. The state is the imported
  /// recipe's id once saved, null before anything is imported, or an
  /// [ImportFailure].
  UrlImportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'urlImportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$urlImportHash();

  @$internal
  @override
  UrlImport create() => UrlImport();
}

String _$urlImportHash() => r'ceeb0ff47b8ffbb645a16e2650b9532480907a28';

/// Imports a recipe from a web address. The state is the imported
/// recipe's id once saved, null before anything is imported, or an
/// [ImportFailure].

abstract class _$UrlImport extends $AsyncNotifier<RecipeId?> {
  FutureOr<RecipeId?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<RecipeId?>, RecipeId?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RecipeId?>, RecipeId?>,
              AsyncValue<RecipeId?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
