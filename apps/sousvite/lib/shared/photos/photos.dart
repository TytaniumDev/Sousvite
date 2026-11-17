import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/shared/photos/photo_picker.dart';
import 'package:sousvite/shared/photos/photo_store.dart';
import 'package:sousvite/shared/photos/platform_photo_store.dart';
import 'package:sousvite/shared/photos/recipe_photos.dart';
import 'package:uuid/uuid.dart';

export 'package:sousvite/shared/photos/photo_picker.dart'
    show PhotoPicker, PhotoSource;
export 'package:sousvite/shared/photos/photo_store.dart' show PhotoStore;
export 'package:sousvite/shared/photos/recipe_photos.dart' show RecipePhotos;
export 'package:sousvite/shared/photos/shrink_photo.dart' show PhotoFailure;

part 'photos.g.dart';

/// Recipe photos on this device. Tests override this with a fake.
@Riverpod(keepAlive: true)
PhotoStore photoStore(Ref ref) => platformPhotoStore();

/// The system camera and photo picker. Tests override this with a fake.
@Riverpod(keepAlive: true)
PhotoPicker photoPicker(Ref ref) => ImagePickerPhotoPicker();

/// Saves, imports, and shows recipe photos.
@Riverpod(keepAlive: true)
RecipePhotos recipePhotos(Ref ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return RecipePhotos(
    store: ref.watch(photoStoreProvider),
    download: (url) async {
      final response = await client.get(url);
      if (response.statusCode != 200) {
        throw http.ClientException('HTTP ${response.statusCode}', url);
      }
      return response.bodyBytes;
    },
    newId: const Uuid().v4,
  );
}
