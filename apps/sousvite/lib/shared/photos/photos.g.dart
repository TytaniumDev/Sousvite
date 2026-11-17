// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photos.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Recipe photos on this device. Tests override this with a fake.

@ProviderFor(photoStore)
final photoStoreProvider = PhotoStoreProvider._();

/// Recipe photos on this device. Tests override this with a fake.

final class PhotoStoreProvider
    extends $FunctionalProvider<PhotoStore, PhotoStore, PhotoStore>
    with $Provider<PhotoStore> {
  /// Recipe photos on this device. Tests override this with a fake.
  PhotoStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoStoreHash();

  @$internal
  @override
  $ProviderElement<PhotoStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PhotoStore create(Ref ref) {
    return photoStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotoStore>(value),
    );
  }
}

String _$photoStoreHash() => r'b107ac517c585132d2a1e674291ddf6ef225ce8d';

/// The system camera and photo picker. Tests override this with a fake.

@ProviderFor(photoPicker)
final photoPickerProvider = PhotoPickerProvider._();

/// The system camera and photo picker. Tests override this with a fake.

final class PhotoPickerProvider
    extends $FunctionalProvider<PhotoPicker, PhotoPicker, PhotoPicker>
    with $Provider<PhotoPicker> {
  /// The system camera and photo picker. Tests override this with a fake.
  PhotoPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoPickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoPickerHash();

  @$internal
  @override
  $ProviderElement<PhotoPicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PhotoPicker create(Ref ref) {
    return photoPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoPicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotoPicker>(value),
    );
  }
}

String _$photoPickerHash() => r'b71d30bec047cf99e031ecba15124a094c433ac0';

/// Saves, imports, and shows recipe photos.

@ProviderFor(recipePhotos)
final recipePhotosProvider = RecipePhotosProvider._();

/// Saves, imports, and shows recipe photos.

final class RecipePhotosProvider
    extends $FunctionalProvider<RecipePhotos, RecipePhotos, RecipePhotos>
    with $Provider<RecipePhotos> {
  /// Saves, imports, and shows recipe photos.
  RecipePhotosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recipePhotosProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recipePhotosHash();

  @$internal
  @override
  $ProviderElement<RecipePhotos> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecipePhotos create(Ref ref) {
    return recipePhotos(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecipePhotos value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecipePhotos>(value),
    );
  }
}

String _$recipePhotosHash() => r'7e81874f81067585e5263cd5b23cc06ec4f35eb6';
