// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_awake.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The screen wake lock.

@ProviderFor(screenAwake)
final screenAwakeProvider = ScreenAwakeProvider._();

/// The screen wake lock.

final class ScreenAwakeProvider
    extends $FunctionalProvider<ScreenAwake, ScreenAwake, ScreenAwake>
    with $Provider<ScreenAwake> {
  /// The screen wake lock.
  ScreenAwakeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'screenAwakeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$screenAwakeHash();

  @$internal
  @override
  $ProviderElement<ScreenAwake> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ScreenAwake create(Ref ref) {
    return screenAwake(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScreenAwake value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScreenAwake>(value),
    );
  }
}

String _$screenAwakeHash() => r'eddb323c3ca6ec7d2a72fb496b524bf734903478';
