// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_importers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches pages straight from the site on iOS and Android, and through
/// the fetch proxy on web.

@ProviderFor(urlImporter)
final urlImporterProvider = UrlImporterProvider._();

/// Fetches pages straight from the site on iOS and Android, and through
/// the fetch proxy on web.

final class UrlImporterProvider
    extends $FunctionalProvider<UrlImporter, UrlImporter, UrlImporter>
    with $Provider<UrlImporter> {
  /// Fetches pages straight from the site on iOS and Android, and through
  /// the fetch proxy on web.
  UrlImporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'urlImporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$urlImporterHash();

  @$internal
  @override
  $ProviderElement<UrlImporter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UrlImporter create(Ref ref) {
    return urlImporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UrlImporter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UrlImporter>(value),
    );
  }
}

String _$urlImporterHash() => r'bd21ea927bad6a7dbde9bc1246a389ca0ae3d144';

/// The whole library, through the system file picker.

@ProviderFor(umamiTransfer)
final umamiTransferProvider = UmamiTransferProvider._();

/// The whole library, through the system file picker.

final class UmamiTransferProvider
    extends $FunctionalProvider<UmamiTransfer, UmamiTransfer, UmamiTransfer>
    with $Provider<UmamiTransfer> {
  /// The whole library, through the system file picker.
  UmamiTransferProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'umamiTransferProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$umamiTransferHash();

  @$internal
  @override
  $ProviderElement<UmamiTransfer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UmamiTransfer create(Ref ref) {
    return umamiTransfer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UmamiTransfer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UmamiTransfer>(value),
    );
  }
}

String _$umamiTransferHash() => r'495f45638721acc2b4a1b2ea6d31f53f97f9722a';
