// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groceryActions)
final groceryActionsProvider = GroceryActionsProvider._();

final class GroceryActionsProvider
    extends $FunctionalProvider<GroceryActions, GroceryActions, GroceryActions>
    with $Provider<GroceryActions> {
  GroceryActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groceryActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groceryActionsHash();

  @$internal
  @override
  $ProviderElement<GroceryActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroceryActions create(Ref ref) {
    return groceryActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroceryActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroceryActions>(value),
    );
  }
}

String _$groceryActionsHash() => r'a318507f2dd9ff13698af14c9d2177bee2c33c42';
