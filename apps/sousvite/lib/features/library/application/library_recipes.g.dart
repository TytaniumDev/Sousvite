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

/// The ids of the recipes in one folder.

@ProviderFor(folderRecipeIds)
final folderRecipeIdsProvider = FolderRecipeIdsFamily._();

/// The ids of the recipes in one folder.

final class FolderRecipeIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecipeId>>,
          List<RecipeId>,
          Stream<List<RecipeId>>
        >
    with $FutureModifier<List<RecipeId>>, $StreamProvider<List<RecipeId>> {
  /// The ids of the recipes in one folder.
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

/// The ids of the recipes in one folder.

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

  /// The ids of the recipes in one folder.

  FolderRecipeIdsProvider call(FolderId folderId) =>
      FolderRecipeIdsProvider._(argument: folderId, from: this);

  @override
  String toString() => r'folderRecipeIdsProvider';
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

/// The recipes the library shows: those in the chosen folder that match
/// the search, newest first.

@ProviderFor(visibleRecipeIds)
final visibleRecipeIdsProvider = VisibleRecipeIdsProvider._();

/// The recipes the library shows: those in the chosen folder that match
/// the search, newest first.

final class VisibleRecipeIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecipeId>>,
          AsyncValue<List<RecipeId>>,
          AsyncValue<List<RecipeId>>
        >
    with $Provider<AsyncValue<List<RecipeId>>> {
  /// The recipes the library shows: those in the chosen folder that match
  /// the search, newest first.
  VisibleRecipeIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visibleRecipeIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visibleRecipeIdsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<RecipeId>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<RecipeId>> create(Ref ref) {
    return visibleRecipeIds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<RecipeId>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<RecipeId>>>(value),
    );
  }
}

String _$visibleRecipeIdsHash() => r'ce88f01cf3806fb6abb0f1c345e24624e69b9cd2';
