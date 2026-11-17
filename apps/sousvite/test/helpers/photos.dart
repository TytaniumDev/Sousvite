import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// A small real JPEG, [width] by [height], for tests that decode photos.
Uint8List testJpeg({int width = 4, int height = 3}) => img.encodeJpg(
  img.Image(width: width, height: height)..clear(img.ColorRgb8(200, 80, 40)),
);
