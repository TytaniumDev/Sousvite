// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barcode_camera.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The device camera, through mobile_scanner. Widget tests override this
/// with a fake, since the camera needs a device or browser.

@ProviderFor(barcodeCamera)
final barcodeCameraProvider = BarcodeCameraProvider._();

/// The device camera, through mobile_scanner. Widget tests override this
/// with a fake, since the camera needs a device or browser.

final class BarcodeCameraProvider
    extends
        $FunctionalProvider<
          BarcodeCameraBuilder,
          BarcodeCameraBuilder,
          BarcodeCameraBuilder
        >
    with $Provider<BarcodeCameraBuilder> {
  /// The device camera, through mobile_scanner. Widget tests override this
  /// with a fake, since the camera needs a device or browser.
  BarcodeCameraProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'barcodeCameraProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$barcodeCameraHash();

  @$internal
  @override
  $ProviderElement<BarcodeCameraBuilder> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BarcodeCameraBuilder create(Ref ref) {
    return barcodeCamera(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BarcodeCameraBuilder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BarcodeCameraBuilder>(value),
    );
  }
}

String _$barcodeCameraHash() => r'f082163854c6fc40f6817faf10db9d35ffe223d2';
