import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sousvite/shared/photos/shrink_photo.dart';

/// Where the user gets a photo from.
enum PhotoSource() {
  /// Take one now.
  camera,

  /// Choose one already taken.
  library,
}

/// Lets the user take or choose a photo.
abstract interface class PhotoPicker() {
  /// Whether this device can take a photo here. Web only offers files.
  bool get canTakePhoto;

  /// The photo's bytes, or null if the user cancels.
  Future<Uint8List?> pick(PhotoSource source);
}

// coverage:ignore-start
// Thin calls into the image_picker plugin, which needs a device or browser.
// Widget tests use a fake PhotoPicker instead.

/// The system camera and photo picker, through image_picker. Asks for a
/// JPEG at most [maxPhotoSide] wide, which also turns iPhone HEIC photos
/// into something every platform can read.
class ImagePickerPhotoPicker() implements PhotoPicker {
  final _picker = ImagePicker();

  @override
  bool get canTakePhoto =>
      !kIsWeb && _picker.supportsImageSource(ImageSource.camera);

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: switch (source) {
        .camera => ImageSource.camera,
        .library => ImageSource.gallery,
      },
      maxWidth: maxPhotoSide.toDouble(),
      maxHeight: maxPhotoSide.toDouble(),
      imageQuality: 90,
    );
    return await file?.readAsBytes();
  }
}

// coverage:ignore-end
