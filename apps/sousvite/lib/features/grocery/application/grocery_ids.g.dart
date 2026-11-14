// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_ids.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groceryIds)
final groceryIdsProvider = GroceryIdsProvider._();

final class GroceryIdsProvider
    extends $FunctionalProvider<GroceryIds, GroceryIds, GroceryIds>
    with $Provider<GroceryIds> {
  GroceryIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groceryIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groceryIdsHash();

  @$internal
  @override
  $ProviderElement<GroceryIds> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroceryIds create(Ref ref) {
    return groceryIds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroceryIds value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroceryIds>(value),
    );
  }
}

String _$groceryIdsHash() => r'0578e5c335ed44e5ae631cfb12d800b1e90ee1ce';
