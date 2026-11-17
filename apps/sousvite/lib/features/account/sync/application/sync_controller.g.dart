// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps the library in sync with the chosen cloud while the app runs
/// (ENGINEERING.md §8.2 and §10).
///
/// It syncs when it starts, a moment after each local change, when the
/// app comes back to the foreground, and when the transport says other
/// devices pushed (Firestore's listener) or every few minutes (Drive). The
/// first sync through a transport, and the first after switching to it,
/// copies the whole library into it as a snapshot (the `replay()` of
/// ENGINEERING.md §8.2) and pushes this device's own changes, which is how
/// signing in for the first time and switching sources lose nothing.

@ProviderFor(SyncController)
final syncControllerProvider = SyncControllerProvider._();

/// Keeps the library in sync with the chosen cloud while the app runs
/// (ENGINEERING.md §8.2 and §10).
///
/// It syncs when it starts, a moment after each local change, when the
/// app comes back to the foreground, and when the transport says other
/// devices pushed (Firestore's listener) or every few minutes (Drive). The
/// first sync through a transport, and the first after switching to it,
/// copies the whole library into it as a snapshot (the `replay()` of
/// ENGINEERING.md §8.2) and pushes this device's own changes, which is how
/// signing in for the first time and switching sources lose nothing.
final class SyncControllerProvider
    extends $NotifierProvider<SyncController, SyncState> {
  /// Keeps the library in sync with the chosen cloud while the app runs
  /// (ENGINEERING.md §8.2 and §10).
  ///
  /// It syncs when it starts, a moment after each local change, when the
  /// app comes back to the foreground, and when the transport says other
  /// devices pushed (Firestore's listener) or every few minutes (Drive). The
  /// first sync through a transport, and the first after switching to it,
  /// copies the whole library into it as a snapshot (the `replay()` of
  /// ENGINEERING.md §8.2) and pushes this device's own changes, which is how
  /// signing in for the first time and switching sources lose nothing.
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

String _$syncControllerHash() => r'accb8c4dba779d33aa3ace79714a859cc3a1c7b0';

/// Keeps the library in sync with the chosen cloud while the app runs
/// (ENGINEERING.md §8.2 and §10).
///
/// It syncs when it starts, a moment after each local change, when the
/// app comes back to the foreground, and when the transport says other
/// devices pushed (Firestore's listener) or every few minutes (Drive). The
/// first sync through a transport, and the first after switching to it,
/// copies the whole library into it as a snapshot (the `replay()` of
/// ENGINEERING.md §8.2) and pushes this device's own changes, which is how
/// signing in for the first time and switching sources lose nothing.

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
