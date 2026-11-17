// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_transport.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Access tokens for the user's Drive app folder.

@ProviderFor(driveAccess)
final driveAccessProvider = DriveAccessProvider._();

/// Access tokens for the user's Drive app folder.

final class DriveAccessProvider
    extends $FunctionalProvider<DriveAccess, DriveAccess, DriveAccess>
    with $Provider<DriveAccess> {
  /// Access tokens for the user's Drive app folder.
  DriveAccessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driveAccessProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driveAccessHash();

  @$internal
  @override
  $ProviderElement<DriveAccess> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DriveAccess create(Ref ref) {
    return driveAccess(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriveAccess value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriveAccess>(value),
    );
  }
}

String _$driveAccessHash() => r'44fb6dfe182e910a9686558bcb1a2fb2eef85c2e';

/// Sousvite cloud spaces over Firestore and Cloud Storage, or null in
/// builds without Firebase.

@ProviderFor(cloudSpaces)
final cloudSpacesProvider = CloudSpacesProvider._();

/// Sousvite cloud spaces over Firestore and Cloud Storage, or null in
/// builds without Firebase.

final class CloudSpacesProvider
    extends
        $FunctionalProvider<
          CloudSpaceFactory?,
          CloudSpaceFactory?,
          CloudSpaceFactory?
        >
    with $Provider<CloudSpaceFactory?> {
  /// Sousvite cloud spaces over Firestore and Cloud Storage, or null in
  /// builds without Firebase.
  CloudSpacesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudSpacesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudSpacesHash();

  @$internal
  @override
  $ProviderElement<CloudSpaceFactory?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CloudSpaceFactory? create(Ref ref) {
    return cloudSpaces(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloudSpaceFactory? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloudSpaceFactory?>(value),
    );
  }
}

String _$cloudSpacesHash() => r'5a94dff4de668fe2b33f2b4023ba923bfdb99346';

/// The one place the app picks how the library syncs (ENGINEERING.md §10):
/// Sousvite cloud or the user's Google Drive, from the Sync source setting.
/// Null while signed out, in builds without Firebase, or when the chosen
/// source can't be used, as Drive with an Apple account. Nothing else in
/// the app knows which transport is active.

@ProviderFor(syncTransport)
final syncTransportProvider = SyncTransportProvider._();

/// The one place the app picks how the library syncs (ENGINEERING.md §10):
/// Sousvite cloud or the user's Google Drive, from the Sync source setting.
/// Null while signed out, in builds without Firebase, or when the chosen
/// source can't be used, as Drive with an Apple account. Nothing else in
/// the app knows which transport is active.

final class SyncTransportProvider
    extends
        $FunctionalProvider<SpaceTransport?, SpaceTransport?, SpaceTransport?>
    with $Provider<SpaceTransport?> {
  /// The one place the app picks how the library syncs (ENGINEERING.md §10):
  /// Sousvite cloud or the user's Google Drive, from the Sync source setting.
  /// Null while signed out, in builds without Firebase, or when the chosen
  /// source can't be used, as Drive with an Apple account. Nothing else in
  /// the app knows which transport is active.
  SyncTransportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncTransportProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncTransportHash();

  @$internal
  @override
  $ProviderElement<SpaceTransport?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpaceTransport? create(Ref ref) {
    return syncTransport(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpaceTransport? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpaceTransport?>(value),
    );
  }
}

String _$syncTransportHash() => r'ee6122f43f9e53cd18666a54e97bb6ffe5050fcb';

/// The joint shares, each syncing through Sousvite cloud whatever the Sync
/// source is. Empty while signed out or in builds without Firebase.

@ProviderFor(sharedSyncTransports)
final sharedSyncTransportsProvider = SharedSyncTransportsProvider._();

/// The joint shares, each syncing through Sousvite cloud whatever the Sync
/// source is. Empty while signed out or in builds without Firebase.

final class SharedSyncTransportsProvider
    extends
        $FunctionalProvider<
          List<SpaceTransport>,
          List<SpaceTransport>,
          List<SpaceTransport>
        >
    with $Provider<List<SpaceTransport>> {
  /// The joint shares, each syncing through Sousvite cloud whatever the Sync
  /// source is. Empty while signed out or in builds without Firebase.
  SharedSyncTransportsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedSyncTransportsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedSyncTransportsHash();

  @$internal
  @override
  $ProviderElement<List<SpaceTransport>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SpaceTransport> create(Ref ref) {
    return sharedSyncTransports(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SpaceTransport> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SpaceTransport>>(value),
    );
  }
}

String _$sharedSyncTransportsHash() =>
    r'f88c23150848352ec36f274af9820e14099e45ba';

/// The device's database as the sync engine sees it, with an applier for
/// every entity kind a repository stores.

@ProviderFor(syncLocalStore)
final syncLocalStoreProvider = SyncLocalStoreProvider._();

/// The device's database as the sync engine sees it, with an applier for
/// every entity kind a repository stores.

final class SyncLocalStoreProvider
    extends $FunctionalProvider<LocalStore, LocalStore, LocalStore>
    with $Provider<LocalStore> {
  /// The device's database as the sync engine sees it, with an applier for
  /// every entity kind a repository stores.
  SyncLocalStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncLocalStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncLocalStoreHash();

  @$internal
  @override
  $ProviderElement<LocalStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalStore create(Ref ref) {
    return syncLocalStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalStore>(value),
    );
  }
}

String _$syncLocalStoreHash() => r'861f240478ed5c8975d6c214cc37dfa4b6c9a9a5';
