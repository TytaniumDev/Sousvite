// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_spaces.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The joint shares the signed-in user is a member of, by space id. Each
/// one syncs through Sousvite cloud next to the private library
/// (ENGINEERING.md §9.1). Empty until sharing fills it in.

@ProviderFor(sharedSpaceIds)
final sharedSpaceIdsProvider = SharedSpaceIdsProvider._();

/// The joint shares the signed-in user is a member of, by space id. Each
/// one syncs through Sousvite cloud next to the private library
/// (ENGINEERING.md §9.1). Empty until sharing fills it in.

final class SharedSpaceIdsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// The joint shares the signed-in user is a member of, by space id. Each
  /// one syncs through Sousvite cloud next to the private library
  /// (ENGINEERING.md §9.1). Empty until sharing fills it in.
  SharedSpaceIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedSpaceIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedSpaceIdsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return sharedSpaceIds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$sharedSpaceIdsHash() => r'164e7a9538d3f94a26993346335911c86a9a4763';
