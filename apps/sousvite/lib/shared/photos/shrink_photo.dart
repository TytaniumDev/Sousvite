import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// A file that isn't a photo the app can read.
final class const PhotoFailure() implements Exception {
  @override
  String toString() => 'PhotoFailure: not a readable image';
}

/// The longest side a saved photo keeps, in pixels. Sharp on a tablet's
/// full-width recipe page, and a few hundred kilobytes as a JPEG.
const maxPhotoSide = 1600;

/// [bytes] as a JPEG no larger than [maxPhotoSide] on its longest side,
/// turned upright, with any transparency on white. Throws [PhotoFailure]
/// when [bytes] isn't an image.
///
/// Slow for large photos: run it with `compute`.
Uint8List shrinkPhoto(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const PhotoFailure();
  var photo = img.bakeOrientation(decoded);
  if (photo.width > maxPhotoSide || photo.height > maxPhotoSide) {
    final landscape = photo.width >= photo.height;
    photo = img.copyResize(
      photo,
      width: landscape ? maxPhotoSide : null,
      height: landscape ? null : maxPhotoSide,
      interpolation: .average,
    );
  }
  if (photo.hasAlpha) {
    photo = img.compositeImage(
      img.Image(width: photo.width, height: photo.height)
        ..clear(img.ColorRgb8(255, 255, 255)),
      photo,
    );
  }
  return img.encodeJpg(photo, quality: 85);
}
