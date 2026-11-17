// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_spaces.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the app reads which joint shares the user is in, or null in
/// builds without Firebase.

@ProviderFor(spaceMemberships)
final spaceMembershipsProvider = SpaceMembershipsProvider._();

/// Where the app reads which joint shares the user is in, or null in
/// builds without Firebase.

final class SpaceMembershipsProvider
    extends
        $FunctionalProvider<
          SpaceMemberships?,
          SpaceMemberships?,
          SpaceMemberships?
        >
    with $Provider<SpaceMemberships?> {
  /// Where the app reads which joint shares the user is in, or null in
  /// builds without Firebase.
  SpaceMembershipsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spaceMembershipsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spaceMembershipsHash();

  @$internal
  @override
  $ProviderElement<SpaceMemberships?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SpaceMemberships? create(Ref ref) {
    return spaceMemberships(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpaceMemberships? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpaceMemberships?>(value),
    );
  }
}

String _$spaceMembershipsHash() => r'53d6ed279f31c9e800690c342598b12e375ae6e0';

/// The joint shares the signed-in user is in, live: joining, starting, or
/// leaving one changes it. Empty while signed out or without Firebase.

@ProviderFor(sharedSpaceMemberships)
final sharedSpaceMembershipsProvider = SharedSpaceMembershipsProvider._();

/// The joint shares the signed-in user is in, live: joining, starting, or
/// leaving one changes it. Empty while signed out or without Firebase.

final class SharedSpaceMembershipsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  /// The joint shares the signed-in user is in, live: joining, starting, or
  /// leaving one changes it. Empty while signed out or without Firebase.
  SharedSpaceMembershipsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedSpaceMembershipsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedSpaceMembershipsHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return sharedSpaceMemberships(ref);
  }
}

String _$sharedSpaceMembershipsHash() =>
    r'1e8c2cb6ec95b799ff50669232a5304272ae03da';

/// The joint shares the signed-in user is a member of, by space id. Each
/// one syncs through Sousvite cloud next to the private library
/// (ENGINEERING.md §9.1). Keeps the last known list while offline.

@ProviderFor(sharedSpaceIds)
final sharedSpaceIdsProvider = SharedSpaceIdsProvider._();

/// The joint shares the signed-in user is a member of, by space id. Each
/// one syncs through Sousvite cloud next to the private library
/// (ENGINEERING.md §9.1). Keeps the last known list while offline.

final class SharedSpaceIdsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// The joint shares the signed-in user is a member of, by space id. Each
  /// one syncs through Sousvite cloud next to the private library
  /// (ENGINEERING.md §9.1). Keeps the last known list while offline.
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

String _$sharedSpaceIdsHash() => r'023fd2fd2bb01745d8c04ca1066d78c86c1925ce';
