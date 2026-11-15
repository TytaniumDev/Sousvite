// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The grocery list the app shows, or null before anything was added.
///
/// The app keeps one list (the nav destination is "Grocery list"), so this
/// is the oldest list. Recipes are added to it until it is cleared.

@ProviderFor(currentGroceryListId)
final currentGroceryListIdProvider = CurrentGroceryListIdProvider._();

/// The grocery list the app shows, or null before anything was added.
///
/// The app keeps one list (the nav destination is "Grocery list"), so this
/// is the oldest list. Recipes are added to it until it is cleared.

final class CurrentGroceryListIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<GroceryListId?>,
          GroceryListId?,
          Stream<GroceryListId?>
        >
    with $FutureModifier<GroceryListId?>, $StreamProvider<GroceryListId?> {
  /// The grocery list the app shows, or null before anything was added.
  ///
  /// The app keeps one list (the nav destination is "Grocery list"), so this
  /// is the oldest list. Recipes are added to it until it is cleared.
  CurrentGroceryListIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentGroceryListIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentGroceryListIdHash();

  @$internal
  @override
  $StreamProviderElement<GroceryListId?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<GroceryListId?> create(Ref ref) {
    return currentGroceryListId(ref);
  }
}

String _$currentGroceryListIdHash() =>
    r'81041c470b0c64687061002439041b4809aeb959';

/// The items on the current list, in list order.

@ProviderFor(groceryItems)
final groceryItemsProvider = GroceryItemsProvider._();

/// The items on the current list, in list order.

final class GroceryItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroceryItem>>,
          List<GroceryItem>,
          Stream<List<GroceryItem>>
        >
    with
        $FutureModifier<List<GroceryItem>>,
        $StreamProvider<List<GroceryItem>> {
  /// The items on the current list, in list order.
  GroceryItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groceryItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groceryItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<GroceryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroceryItem>> create(Ref ref) {
    return groceryItems(ref);
  }
}

String _$groceryItemsHash() => r'4aa7e777715a72f4d80ae35f8a180918a90968b5';

/// The current list combined and grouped for display.
///
/// Widgets `select` the part they show, such as one entry, so a change to
/// one item rebuilds only its row (ENGINEERING.md §5).

@ProviderFor(groceryView)
final groceryViewProvider = GroceryViewProvider._();

/// The current list combined and grouped for display.
///
/// Widgets `select` the part they show, such as one entry, so a change to
/// one item rebuilds only its row (ENGINEERING.md §5).

final class GroceryViewProvider
    extends
        $FunctionalProvider<
          AsyncValue<GroceryView>,
          AsyncValue<GroceryView>,
          AsyncValue<GroceryView>
        >
    with $Provider<AsyncValue<GroceryView>> {
  /// The current list combined and grouped for display.
  ///
  /// Widgets `select` the part they show, such as one entry, so a change to
  /// one item rebuilds only its row (ENGINEERING.md §5).
  GroceryViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groceryViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groceryViewHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<GroceryView>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<GroceryView> create(Ref ref) {
    return groceryView(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<GroceryView> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<GroceryView>>(value),
    );
  }
}

String _$groceryViewHash() => r'7fecf728c2bf5a88a49f6519b9460d676a742a5d';

/// A recipe's title, for showing where a grocery entry came from. Null while
/// loading and once the recipe is deleted.

@ProviderFor(groceryRecipeTitle)
final groceryRecipeTitleProvider = GroceryRecipeTitleFamily._();

/// A recipe's title, for showing where a grocery entry came from. Null while
/// loading and once the recipe is deleted.

final class GroceryRecipeTitleProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// A recipe's title, for showing where a grocery entry came from. Null while
  /// loading and once the recipe is deleted.
  GroceryRecipeTitleProvider._({
    required GroceryRecipeTitleFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'groceryRecipeTitleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groceryRecipeTitleHash();

  @override
  String toString() {
    return r'groceryRecipeTitleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return groceryRecipeTitle(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroceryRecipeTitleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groceryRecipeTitleHash() =>
    r'2fbf1375e91798913e5575c9e46d4a784a8c0b9f';

/// A recipe's title, for showing where a grocery entry came from. Null while
/// loading and once the recipe is deleted.

final class GroceryRecipeTitleFamily extends $Family
    with $FunctionalFamilyOverride<Stream<String?>, RecipeId> {
  GroceryRecipeTitleFamily._()
    : super(
        retry: null,
        name: r'groceryRecipeTitleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A recipe's title, for showing where a grocery entry came from. Null while
  /// loading and once the recipe is deleted.

  GroceryRecipeTitleProvider call(RecipeId recipeId) =>
      GroceryRecipeTitleProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'groceryRecipeTitleProvider';
}

/// A recipe's ingredient lines, for the add-to-list sheet.

@ProviderFor(groceryRecipeLines)
final groceryRecipeLinesProvider = GroceryRecipeLinesFamily._();

/// A recipe's ingredient lines, for the add-to-list sheet.

final class GroceryRecipeLinesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IngredientLine>>,
          List<IngredientLine>,
          Stream<List<IngredientLine>>
        >
    with
        $FutureModifier<List<IngredientLine>>,
        $StreamProvider<List<IngredientLine>> {
  /// A recipe's ingredient lines, for the add-to-list sheet.
  GroceryRecipeLinesProvider._({
    required GroceryRecipeLinesFamily super.from,
    required RecipeId super.argument,
  }) : super(
         retry: null,
         name: r'groceryRecipeLinesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groceryRecipeLinesHash();

  @override
  String toString() {
    return r'groceryRecipeLinesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<IngredientLine>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<IngredientLine>> create(Ref ref) {
    final argument = this.argument as RecipeId;
    return groceryRecipeLines(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroceryRecipeLinesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groceryRecipeLinesHash() =>
    r'e83f65920f4a86891f2ea00ed79ad760f6025883';

/// A recipe's ingredient lines, for the add-to-list sheet.

final class GroceryRecipeLinesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<IngredientLine>>, RecipeId> {
  GroceryRecipeLinesFamily._()
    : super(
        retry: null,
        name: r'groceryRecipeLinesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A recipe's ingredient lines, for the add-to-list sheet.

  GroceryRecipeLinesProvider call(RecipeId recipeId) =>
      GroceryRecipeLinesProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'groceryRecipeLinesProvider';
}
