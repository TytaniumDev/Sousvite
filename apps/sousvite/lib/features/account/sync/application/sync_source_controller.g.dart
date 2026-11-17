// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_source_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Sync source setting (Beta): Sousvite cloud by default during the
/// beta, or the user's Google Drive (ENGINEERING.md §10). Kept on this
/// device.
///
/// Switching goes through `SyncController.switchTo`, which copies the
/// library into the new source before choosing it.

@ProviderFor(SyncSourceController)
final syncSourceControllerProvider = SyncSourceControllerProvider._();

/// The Sync source setting (Beta): Sousvite cloud by default during the
/// beta, or the user's Google Drive (ENGINEERING.md §10). Kept on this
/// device.
///
/// Switching goes through `SyncController.switchTo`, which copies the
/// library into the new source before choosing it.
final class SyncSourceControllerProvider
    extends $AsyncNotifierProvider<SyncSourceController, SyncSource> {
  /// The Sync source setting (Beta): Sousvite cloud by default during the
  /// beta, or the user's Google Drive (ENGINEERING.md §10). Kept on this
  /// device.
  ///
  /// Switching goes through `SyncController.switchTo`, which copies the
  /// library into the new source before choosing it.
  SyncSourceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncSourceControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncSourceControllerHash();

  @$internal
  @override
  SyncSourceController create() => SyncSourceController();
}

String _$syncSourceControllerHash() =>
    r'f667e90cae0ac29661facb08ca6dfa0a874bb5b2';

/// The Sync source setting (Beta): Sousvite cloud by default during the
/// beta, or the user's Google Drive (ENGINEERING.md §10). Kept on this
/// device.
///
/// Switching goes through `SyncController.switchTo`, which copies the
/// library into the new source before choosing it.

abstract class _$SyncSourceController extends $AsyncNotifier<SyncSource> {
  FutureOr<SyncSource> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SyncSource>, SyncSource>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SyncSource>, SyncSource>,
              AsyncValue<SyncSource>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
