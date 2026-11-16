import 'dart:typed_data';

import 'package:sousvite/shared/photos/photo_picker.dart';

/// A [PhotoPicker] that hands over [next], and records each request.
class FakePhotoPicker({
  /// Whether the camera is offered.
  @override final bool canTakePhoto = true,
}) implements PhotoPicker {
  /// The bytes the next pick returns; null acts like the user canceling.
  Uint8List? next;

  /// Every source asked for, in order.
  final List<PhotoSource> requests = [];

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    requests.add(source);
    return next;
  }
}
