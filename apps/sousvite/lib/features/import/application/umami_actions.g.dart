// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'umami_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs one Umami import or export at a time. The state is the running
/// task, or null when idle.

@ProviderFor(UmamiActions)
final umamiActionsProvider = UmamiActionsProvider._();

/// Runs one Umami import or export at a time. The state is the running
/// task, or null when idle.
final class UmamiActionsProvider
    extends $NotifierProvider<UmamiActions, UmamiTask?> {
  /// Runs one Umami import or export at a time. The state is the running
  /// task, or null when idle.
  UmamiActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'umamiActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$umamiActionsHash();

  @$internal
  @override
  UmamiActions create() => UmamiActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UmamiTask? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UmamiTask?>(value),
    );
  }
}

String _$umamiActionsHash() => r'1fb09b387acb6238fab7dba6b195f8406e04c3d2';

/// Runs one Umami import or export at a time. The state is the running
/// task, or null when idle.

abstract class _$UmamiActions extends $Notifier<UmamiTask?> {
  UmamiTask? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UmamiTask?, UmamiTask?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UmamiTask?, UmamiTask?>,
              UmamiTask?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
