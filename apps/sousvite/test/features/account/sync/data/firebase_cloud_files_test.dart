import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/account/sync/data/firebase_cloud_files.dart';

/// Storage whose every lookup fails with [code].
class _FailingStorage(final String code)
    extends Fake
    implements FirebaseStorage {
  @override
  Reference ref([String? path]) => _FailingReference(code);
}

class _FailingReference(final String code) extends Fake implements Reference {
  FirebaseException get _error =>
      FirebaseException(plugin: 'firebase_storage', code: code);

  @override
  Future<FullMetadata> getMetadata() => Future.error(_error);

  @override
  Future<Uint8List?> getData([int maxSize = 10485760]) => Future.error(_error);
}

void main() {
  group(FirebaseCloudFiles, () {
    test('uploads typed and downloads back', () async {
      final storage = MockFirebaseStorage();
      final files = FirebaseCloudFiles(storage);
      const path = 'spaces/u_a/photos/p1';

      await files.upload(
        path,
        Uint8List.fromList([1, 2]),
        contentType: 'image/jpeg',
      );

      expect(await files.exists(path), isTrue);
      expect(await files.download(path), [1, 2]);
      expect((await storage.ref(path).getMetadata()).contentType, 'image/jpeg');
    });

    test('a missing object does not exist and downloads as null', () async {
      final files = FirebaseCloudFiles(_FailingStorage('object-not-found'));

      expect(await files.exists('spaces/u_a/photos/none'), isFalse);
      expect(await files.download('spaces/u_a/photos/none'), isNull);
    });

    test('other failures pass through', () async {
      final files = FirebaseCloudFiles(_FailingStorage('unauthorized'));

      await expectLater(
        files.exists('spaces/s/photos/p'),
        throwsA(isA<FirebaseException>()),
      );
      await expectLater(
        files.download('spaces/s/photos/p'),
        throwsA(isA<FirebaseException>()),
      );
    });
  });
}
