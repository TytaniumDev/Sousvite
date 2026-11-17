// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sharing_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sharingService)
final sharingServiceProvider = SharingServiceProvider._();

final class SharingServiceProvider
    extends $FunctionalProvider<SharingService, SharingService, SharingService>
    with $Provider<SharingService> {
  SharingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharingServiceHash();

  @$internal
  @override
  $ProviderElement<SharingService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SharingService create(Ref ref) {
    return sharingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharingService>(value),
    );
  }
}

String _$sharingServiceHash() => r'b843ecb1b60091b3c60e956341422ac98978c1f3';
