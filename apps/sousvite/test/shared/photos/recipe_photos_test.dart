import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/shared/photos/recipe_photos.dart';
import 'package:sousvite/shared/photos/shrink_photo.dart';
import 'package:sousvite/shared/photos/stored_photo_image.dart';

import '../../helpers/fakes/fake_photo_store.dart';
import '../../helpers/photos.dart';

void main() {
  late FakePhotoStore store;
  late List<Uri> downloads;
  late RecipePhotos photos;
  final original = Uint8List.fromList([1, 2, 3]);
  final shrunk = Uint8List.fromList([9]);

  setUp(() {
    store = FakePhotoStore();
    downloads = [];
    var nextId = 0;
    photos = RecipePhotos(
      store: store,
      download: (url) async {
        downloads.add(url);
        if (url.host == 'offline.com') throw const SocketException('down');
        return original;
      },
      newId: () => 'photo${nextId++}',
      shrink: (bytes) async {
        if (bytes.isEmpty) throw const PhotoFailure();
        return shrunk;
      },
    );
  });

  group('save', () {
    test('shrinks and saves the photo under a new id', () async {
      expect(await photos.save(original), 'photo0');
      expect(store.photos, {'photo0': shrunk});
    });

    test('saves nothing for a file that is not a photo', () async {
      await expectLater(
        photos.save(Uint8List(0)),
        throwsA(isA<PhotoFailure>()),
      );
      expect(store.photos, isEmpty);
    });

    test('shrinks in the background by default', () async {
      final background = RecipePhotos(
        store: store,
        download: (_) async => original,
        newId: () => 'bg',
      );
      await background.save(testJpeg());
      expect(store.photos['bg'], isNotEmpty);
    });
  });

  group('importFrom', () {
    test('downloads and saves the photo', () async {
      expect(await photos.importFrom(' https://a.com/p.jpg '), 'photo0');
      expect(downloads, [Uri.parse('https://a.com/p.jpg')]);
      expect(store.photos.keys, ['photo0']);
    });

    test('keeps the address when the download fails', () async {
      expect(
        await photos.importFrom('https://offline.com/p.jpg'),
        'https://offline.com/p.jpg',
      );
      expect(store.photos, isEmpty);
    });

    test('ignores no photo, and addresses that are not on the web', () async {
      expect(await photos.importFrom(null), isNull);
      expect(await photos.importFrom('  '), isNull);
      expect(await photos.importFrom('file:///etc/passwd'), isNull);
      expect(downloads, isEmpty);
    });
  });

  group('imageFor', () {
    test('shows a stored photo from the store', () {
      expect(photos.imageFor('photo0'), StoredPhotoImage(store, 'photo0'));
    });

    test('shows a web photo from its address', () {
      expect(
        photos.imageFor('https://a.com/p.jpg'),
        isA<NetworkImage>().having((i) => i.url, 'url', 'https://a.com/p.jpg'),
      );
    });
  });
}
