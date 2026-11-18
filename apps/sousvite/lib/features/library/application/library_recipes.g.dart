// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_recipes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every recipe id, newest first.

@ProviderFor(allRecipeIds)
final allRecipeIdsProvider = AllRecipeIdsProvider._();

/// Every recipe id, newest first.

final class AllRecipeIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecipeId>>,
          List<RecipeId>,
          Stream<List<RecipeId>>
        >
    with $FutureModifier<List<RecipeId>>, $StreamProvider<List<RecipeId>> {
  /// Every recipe id, newest first.
  AllRecipeIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allRecipeIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allRecipeIdsHash();

  @$internal
  @override
  $StreamProviderElement<List<RecipeId>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RecipeId>> create(Ref ref) {
    return allRecipeIds(ref);
  }
}

String _$allRecipeIdsHash() => r'91458677929fd5cdbbe609dba0870f27d5be4e36';

/// The ids of the recipes in one folder, in the repository's order.

@ProviderFor(folderRecipeIds)
final folderRecipeIdsProvider = FolderRecipeIdsFamily._();

/// The ids of the recipes in one folder, in the repository's order.

final class FolderRecipeIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecipeId>>,
          List<RecipeId>,
          Stream<List<RecipeId>>
        >
    with $FutureModifier<List<RecipeId>>, $StreamProvider<List<RecipeId>> {
  /// The ids of the recipes in one folder, in the repository's order.
  FolderRecipeIdsProvider._({
    required FolderRecipeIdsFamily super.from,
    required FolderId super.argument,
  }) : super(
         retry: null,
         name: r'folderRecipeIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$folderRecipeIdsHash();

  @override
  String toString() {
    return r'folderRecipeIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RecipeId>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RecipeId>> create(Ref ref) {
    final argument = this.argument as FolderId;
    return folderRecipeIds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FolderRecipeIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$folderRecipeIdsHash() => r'f0c0a048ecdadab047b2f542359de09cf4fa9b8a';

/// The ids of the recipes in one folder, in the repository's order.

final class FolderRecipeIdsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RecipeId>>, FolderId> {
  FolderRecipeIdsFamily._()
    : super(
        retry: null,
        name: r'folderRecipeIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The ids of the recipes in one folder, in the repository's order.

  FolderRecipeIdsProvider call(FolderId folderId) =>
      FolderRecipeIdsProvider._(argument: folderId, from: this);

  @override
  String toString() => r'folderRecipeIdsProvider';
}

/// The ids of recipes in at least one folder.

@ProviderFor(filedRecipeIds)
final filedRecipeIdsProvider = FiledRecipeIdsProvider._();

/// The ids of recipes in at least one folder.

final class FiledRecipeIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<RecipeId>>,
          Set<RecipeId>,
          Stream<Set<RecipeId>>
        >
    with $FutureModifier<Set<RecipeId>>, $StreamProvider<Set<RecipeId>> {
  /// The ids of recipes in at least one folder.
  FiledRecipeIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filedRecipeIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filedRecipeIdsHash();

  @$internal
  @override
  $StreamProviderElement<Set<RecipeId>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<RecipeId>> create(Ref ref) {
    return filedRecipeIds(ref);
  }
}

String _$filedRecipeIdsHash() => r'30d3aed117420ceb05f2b95ad06e8a5d6530d3af';

/// The recipes in [scope], newest first, before any search.

@ProviderFor(scopeRecipeIds)
final scopeRecipeIdsProvider = ScopeRecipeIdsFamily._();

/// The recipes in [scope], newest first, before any search.

final class ScopeRecipeIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecipeId>>,
          AsyncValue<List<RecipeId>>,
          AsyncValue<List<RecipeId>>
        >
    with $Provider<AsyncValue<List<RecipeId>>> {
  /// The recipes in [scope], newest first, before any search.
  ScopeRecipeIdsProvider._({
    required ScopeRecipeIdsFamily super.from,
    required LibraryScope super.argument,
  }) : super(
         retry: null,
         name: r'scopeRecipeIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$scopeRecipeIdsHash();

  @override
  String toString() {
    return r'scopeRecipeIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<RecipeId>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<RecipeId>> create(Ref ref) {
    final argument = this.argument as LibraryScope;
    return scopeRecipeIds(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<RecipeId>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<RecipeId>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ScopeRecipeIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$scopeRecipeIdsHash() => r'9ff0d4e2bbc50e2b7968868b05547e1fe5a4ee19';

/// The recipes in [scope], newest first, before any search.

final class ScopeRecipeIdsFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<List<RecipeId>>, LibraryScope> {
  ScopeRecipeIdsFamily._()
    : super(
        retry: null,
        name: r'scopeRecipeIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The recipes in [scope], newest first, before any search.

  ScopeRecipeIdsProvider call(LibraryScope scope) =>
      ScopeRecipeIdsProvider._(argument: scope, from: this);

  @override
  String toString() => r'scopeRecipeIdsProvider';
}

/// The ids of recipes matching [query] by title, ingredient, or folder.

@ProviderFor(recipeSearch)
final recipeSearchProvider = RecipeSearchFamily._();

/// The ids of recipes matching [query] by title, ingredient, or folder.

final class RecipeSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecipeId>>,
          List<RecipeId>,
          Stream<List<RecipeId>>
        >
    with $FutureModifier<List<RecipeId>>, $StreamProvider<List<RecipeId>> {
  /// The ids of recipes matching [query] by title, ingredient, or folder.
  RecipeSearchProvider._({
    required RecipeSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recipeSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recipeSearchHash();

  @override
  String toString() {
    return r'recipeSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RecipeId>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RecipeId>> create(Ref ref) {
    final argument = this.argument as String;
    return recipeSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recipeSearchHash() => r'b5d765ff8b9b82c2dbf3abb7dced7c898dac514d';

/// The ids of recipes matching [query] by title, ingredient, or folder.

final class RecipeSearchFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RecipeId>>, String> {
  RecipeSearchFamily._()
    : super(
        retry: null,
        name: r'recipeSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The ids of recipes matching [query] by title, ingredient, or folder.

  RecipeSearchProvider call(String query) =>
      RecipeSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'recipeSearchProvider';
}

/// The recipes the page showing [scope] lists, newest first, kept to those
/// matching its search.

@ProviderFor(visibleRecipeIds)
final visibleRecipeIdsProvider = VisibleRecipeIdsFamily._();

/// The recipes the page showing [scope] lists, newest first, kept to those
/// matching its search.

final class VisibleRecipeIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecipeId>>,
          AsyncValue<List<RecipeId>>,
          AsyncValue<List<RecipeId>>
        >
    with $Provider<AsyncValue<List<RecipeId>>> {
  /// The recipes the page showing [scope] lists, newest first, kept to those
  /// matching its search.
  VisibleRecipeIdsProvider._({
    required VisibleRecipeIdsFamily super.from,
    required LibraryScope super.argument,
  }) : super(
         retry: null,
         name: r'visibleRecipeIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$visibleRecipeIdsHash();

  @override
  String toString() {
    return r'visibleRecipeIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<RecipeId>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<RecipeId>> create(Ref ref) {
    final argument = this.argument as LibraryScope;
    return visibleRecipeIds(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<RecipeId>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<RecipeId>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VisibleRecipeIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$visibleRecipeIdsHash() => r'f587517f70e565d3d2642f2bcdfdc4f510e21967';

/// The recipes the page showing [scope] lists, newest first, kept to those
/// matching its search.

final class VisibleRecipeIdsFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<List<RecipeId>>, LibraryScope> {
  VisibleRecipeIdsFamily._()
    : super(
        retry: null,
        name: r'visibleRecipeIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The recipes the page showing [scope] lists, newest first, kept to those
  /// matching its search.

  VisibleRecipeIdsProvider call(LibraryScope scope) =>
      VisibleRecipeIdsProvider._(argument: scope, from: this);

  @override
  String toString() => r'visibleRecipeIdsProvider';
}

/// How many recipes [scope] holds. Null while loading.

@ProviderFor(scopeRecipeCount)
final scopeRecipeCountProvider = ScopeRecipeCountFamily._();

/// How many recipes [scope] holds. Null while loading.

final class ScopeRecipeCountProvider
    extends $FunctionalProvider<int?, int?, int?>
    with $Provider<int?> {
  /// How many recipes [scope] holds. Null while loading.
  ScopeRecipeCountProvider._({
    required ScopeRecipeCountFamily super.from,
    required LibraryScope super.argument,
  }) : super(
         retry: null,
         name: r'scopeRecipeCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$scopeRecipeCountHash();

  @override
  String toString() {
    return r'scopeRecipeCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int? create(Ref ref) {
    final argument = this.argument as LibraryScope;
    return scopeRecipeCount(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ScopeRecipeCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$scopeRecipeCountHash() => r'dffe1ee300064d7a38743c8bea848ae70b569bdf';

/// How many recipes [scope] holds. Null while loading.

final class ScopeRecipeCountFamily extends $Family
    with $FunctionalFamilyOverride<int?, LibraryScope> {
  ScopeRecipeCountFamily._()
    : super(
        retry: null,
        name: r'scopeRecipeCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How many recipes [scope] holds. Null while loading.

  ScopeRecipeCountProvider call(LibraryScope scope) =>
      ScopeRecipeCountProvider._(argument: scope, from: this);

  @override
  String toString() => r'scopeRecipeCountProvider';
}

/// The photos on a tile: those of the newest recipes in [scope] that have
/// one, at most [maxCount].
///
/// Notifies only when that list changes, so renaming a recipe or adding
/// one without a photo doesn't rebuild the tile.

@ProviderFor(CoverPhotos)
final coverPhotosProvider = CoverPhotosFamily._();

/// The photos on a tile: those of the newest recipes in [scope] that have
/// one, at most [maxCount].
///
/// Notifies only when that list changes, so renaming a recipe or adding
/// one without a photo doesn't rebuild the tile.
final class CoverPhotosProvider
    extends $NotifierProvider<CoverPhotos, List<String>> {
  /// The photos on a tile: those of the newest recipes in [scope] that have
  /// one, at most [maxCount].
  ///
  /// Notifies only when that list changes, so renaming a recipe or adding
  /// one without a photo doesn't rebuild the tile.
  CoverPhotosProvider._({
    required CoverPhotosFamily super.from,
    required LibraryScope super.argument,
  }) : super(
         retry: null,
         name: r'coverPhotosProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$coverPhotosHash();

  @override
  String toString() {
    return r'coverPhotosProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CoverPhotos create() => CoverPhotos();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CoverPhotosProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$coverPhotosHash() => r'acf3432aa1f0cb73549f902e1aec4ca6a096a9f6';

/// The photos on a tile: those of the newest recipes in [scope] that have
/// one, at most [maxCount].
///
/// Notifies only when that list changes, so renaming a recipe or adding
/// one without a photo doesn't rebuild the tile.

final class CoverPhotosFamily extends $Family
    with
        $ClassFamilyOverride<
          CoverPhotos,
          List<String>,
          List<String>,
          List<String>,
          LibraryScope
        > {
  CoverPhotosFamily._()
    : super(
        retry: null,
        name: r'coverPhotosProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The photos on a tile: those of the newest recipes in [scope] that have
  /// one, at most [maxCount].
  ///
  /// Notifies only when that list changes, so renaming a recipe or adding
  /// one without a photo doesn't rebuild the tile.

  CoverPhotosProvider call(LibraryScope scope) =>
      CoverPhotosProvider._(argument: scope, from: this);

  @override
  String toString() => r'coverPhotosProvider';
}

/// The photos on a tile: those of the newest recipes in [scope] that have
/// one, at most [maxCount].
///
/// Notifies only when that list changes, so renaming a recipe or adding
/// one without a photo doesn't rebuild the tile.

abstract class _$CoverPhotos extends $Notifier<List<String>> {
  late final _$args = ref.$arg as LibraryScope;
  LibraryScope get scope => _$args;

  List<String> build(LibraryScope scope);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
