import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/shared/photos/file_photo_store.dart';

void main() {
  late Directory root;
  late FilePhotoStore store;

  setUp(() {
    root = Directory.systemTemp.createTempSync('photos_test');
    addTearDown(() => root.deleteSync(recursive: true));
    store = FilePhotoStore(Future.value(Directory('${root.path}/photos')));
  });

  final bytes = Uint8List.fromList([1, 2, 3]);

  test('writes, reads, and deletes a photo', () async {
    await store.write('a', bytes);
    expect(await store.read('a'), bytes);
    expect(File('${root.path}/photos/a.jpg').existsSync(), isTrue);

    await store.delete('a');
    expect(await store.read('a'), isNull);
  });

  test('reads a missing photo as null, and deleting it does nothing', () async {
    expect(await store.read('missing'), isNull);
    await store.delete('missing');
  });

  test('refuses ids that would leave the folder', () async {
    for (final id in ['', '../x', 'a/b', r'a\b', '.hidden']) {
      await expectLater(store.write(id, bytes), throwsArgumentError);
    }
  });
}
