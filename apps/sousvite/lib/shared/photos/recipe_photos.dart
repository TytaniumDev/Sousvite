import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:sousvite/shared/photos/photo_ref.dart';
import 'package:sousvite/shared/photos/photo_store.dart';
import 'package:sousvite/shared/photos/shrink_photo.dart';
import 'package:sousvite/shared/photos/stored_photo_image.dart';

/// Fetches the bytes at a web address. Throws when it can't.
typedef PhotoDownload = Future<Uint8List> Function(Uri url);

/// Shrinks a photo for saving (see [shrinkPhoto]).
typedef PhotoShrink = Future<Uint8List> Function(Uint8List bytes);

/// Saves recipe photos on this device and finds them again (BUILD_PLAN.md
/// MEDIA-1). A recipe keeps the result in `Recipe.photoRef`.
class const RecipePhotos({
  /// Where photos are saved.
  required final PhotoStore store,

  /// Fetches imported photos.
  required final PhotoDownload download,

  /// Makes a new photo's id.
  required final String Function() newId,

  /// Shrinks a photo before it is saved. Tests pass a fast one.
  final PhotoShrink shrink = _shrinkInBackground,
}) {
  static Future<Uint8List> _shrinkInBackground(Uint8List bytes) =>
      compute(shrinkPhoto, bytes);

  /// Shrinks and saves [bytes], and returns the `photoRef` for it. Throws
  /// [PhotoFailure] when [bytes] isn't an image.
  Future<String> save(Uint8List bytes) async {
    final shrunk = await shrink(bytes);
    final id = newId();
    await store.write(id, shrunk);
    return id;
  }

  /// The `photoRef` for an imported photo at [url]: saved on this device
  /// when it downloads, so it shows offline, or [url] itself when it
  /// can't (offline, or a site that blocks it on web). Null when there's
  /// no photo.
  Future<String?> importFrom(String? url) async {
    if (url == null || url.trim().isEmpty) return null;
    final ref = PhotoRef.parse(url.trim());
    if (ref is! RemotePhoto) return null;
    try {
      return await save(await download(ref.url));
    } on Exception {
      return ref.url.toString();
    }
  }

  /// The image to show for [photoRef]: the saved photo, or the photo on the
  /// web. On web, a site that blocks reading its photos still shows them
  /// in an `<img>` element.
  ImageProvider imageFor(String photoRef) => switch (PhotoRef.parse(photoRef)) {
    StoredPhoto(:final id) => StoredPhotoImage(store, id),
    RemotePhoto(:final url) => NetworkImage(
      url.toString(),
      webHtmlElementStrategy: .fallback,
    ),
  };
}
