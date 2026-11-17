import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sousvite/shared/photos/shrink_photo.dart';

import '../../helpers/photos.dart';

void main() {
  group('shrinkPhoto', () {
    test('shrinks a wide photo to the longest side', () {
      final shrunk = img.decodeJpg(
        shrinkPhoto(testJpeg(width: maxPhotoSide * 2, height: 100)),
      )!;
      expect((shrunk.width, shrunk.height), (maxPhotoSide, 50));
    });

    test('shrinks a tall photo to the longest side', () {
      final shrunk = img.decodeJpg(
        shrinkPhoto(testJpeg(width: 100, height: maxPhotoSide * 2)),
      )!;
      expect((shrunk.width, shrunk.height), (50, maxPhotoSide));
    });

    test('keeps a small photo its size, as a JPEG', () {
      final png = img.encodePng(img.Image(width: 10, height: 8));
      final shrunk = img.decodeJpg(shrinkPhoto(png))!;
      expect((shrunk.width, shrunk.height), (10, 8));
    });

    test('puts transparency on white', () {
      final clear = img.Image(width: 4, height: 4, numChannels: 4)
        ..clear(img.ColorRgba8(0, 0, 0, 0));
      final shrunk = img.decodeJpg(shrinkPhoto(img.encodePng(clear)))!;
      expect(shrunk.getPixel(1, 1).r, greaterThan(240));
    });

    test('turns a photo upright from its orientation tag', () {
      final sideways = img.Image(width: 8, height: 4)
        ..exif.imageIfd.orientation = 6;
      final shrunk = img.decodeJpg(shrinkPhoto(img.encodeJpg(sideways)))!;
      expect((shrunk.width, shrunk.height), (4, 8));
    });

    test('fails for bytes that are not an image', () {
      expect(
        () => shrinkPhoto(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<PhotoFailure>()),
      );
      expect(const PhotoFailure().toString(), contains('PhotoFailure'));
    });
  });
}
