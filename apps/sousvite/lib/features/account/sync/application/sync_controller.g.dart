// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Syncs recipe photos after each space syncs.

@ProviderFor(photoSync)
final photoSyncProvider = PhotoSyncProvider._();

/// Syncs recipe photos after each space syncs.

final class PhotoSyncProvider
    extends $FunctionalProvider<PhotoSync, PhotoSync, PhotoSync>
    with $Provider<PhotoSync> {
  /// Syncs recipe photos after each space syncs.
  PhotoSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoSyncHash();

  @$internal
  @override
  $ProviderElement<PhotoSync> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PhotoSync create(Ref ref) {
    return photoSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoSync value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotoSync>(value),
    );
  }
}

String _$photoSyncHash() => r'2d410f9891de626bd163d55bd28471c4b85c993f';

/// Keeps the library in sync with the chosen cloud while the app runs
/// (ENGINEERING.md §8.2 and §10).
///
/// It syncs when it starts, a moment after each local change, when the
/// app comes back to the foreground, and when the transport says other
/// devices pushed (Firestore's listener) or every few minutes (Drive). The
/// first sync through a transport, and the first after switching to it,
/// pushes this device's own changes and then copies the whole library into
/// it as a snapshot (the `replay()` of ENGINEERING.md §8.2), which is how
/// signing in for the first time and switching sources lose nothing. A
/// snapshot that fails is reported and tried again on the next sync; it
/// never holds back the pushes and pulls.

@ProviderFor(SyncController)
final syncControllerProvider = SyncControllerProvider._();

/// Keeps the library in sync with the chosen cloud while the app runs
/// (ENGINEERING.md §8.2 and §10).
///
/// It syncs when it starts, a moment after each local change, when the
/// app comes back to the foreground, and when the transport says other
/// devices pushed (Firestore's listener) or every few minutes (Drive). The
/// first sync through a transport, and the first after switching to it,
/// pushes this device's own changes and then copies the whole library into
/// it as a snapshot (the `replay()` of ENGINEERING.md §8.2), which is how
/// signing in for the first time and switching sources lose nothing. A
/// snapshot that fails is reported and tried again on the next sync; it
/// never holds back the pushes and pulls.
final class SyncControllerProvider
    extends $NotifierProvider<SyncController, SyncState> {
  /// Keeps the library in sync with the chosen cloud while the app runs
  /// (ENGINEERING.md §8.2 and §10).
  ///
  /// It syncs when it starts, a moment after each local change, when the
  /// app comes back to the foreground, and when the transport says other
  /// devices pushed (Firestore's listener) or every few minutes (Drive). The
  /// first sync through a transport, and the first after switching to it,
  /// pushes this device's own changes and then copies the whole library into
  /// it as a snapshot (the `replay()` of ENGINEERING.md §8.2), which is how
  /// signing in for the first time and switching sources lose nothing. A
  /// snapshot that fails is reported and tried again on the next sync; it
  /// never holds back the pushes and pulls.
  SyncControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncControllerHash();

  @$internal
  @override
  SyncController create() => SyncController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncState>(value),
    );
  }
}

String _$syncControllerHash() => r'4068764bfbbb37f189267be7923c17550b5926c9';

/// Keeps the library in sync with the chosen cloud while the app runs
/// (ENGINEERING.md §8.2 and §10).
///
/// It syncs when it starts, a moment after each local change, when the
/// app comes back to the foreground, and when the transport says other
/// devices pushed (Firestore's listener) or every few minutes (Drive). The
/// first sync through a transport, and the first after switching to it,
/// pushes this device's own changes and then copies the whole library into
/// it as a snapshot (the `replay()` of ENGINEERING.md §8.2), which is how
/// signing in for the first time and switching sources lose nothing. A
/// snapshot that fails is reported and tried again on the next sync; it
/// never holds back the pushes and pulls.

abstract class _$SyncController extends $Notifier<SyncState> {
  SyncState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SyncState, SyncState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SyncState, SyncState>,
              SyncState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
