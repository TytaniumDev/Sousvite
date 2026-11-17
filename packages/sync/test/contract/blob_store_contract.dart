import 'dart:typed_data';

import 'package:sync/sync.dart';
import 'package:test/test.dart';

/// Makes blob stores over one shared backend, the way two devices see the
/// same Drive folder or bucket.
abstract interface class BlobHarness() {
  /// A store over the harness's backend, as one device sees it.
  BlobStore store();
}

/// The behavior every [BlobStore] shares (BUILD_PLAN MEDIA-2).
void runBlobStoreContract(String name, BlobHarness Function() harness) {
  group('$name blob store contract', () {
    late BlobHarness backend;
    final photo = Uint8List.fromList([1, 2, 3]);

    setUp(() => backend = harness());

    test('a stored blob reads back on another device', () async {
      await backend.store().put('p1', photo, contentType: 'image/jpeg');

      expect(await backend.store().get('p1'), photo);
    });

    test('a missing blob reads as null', () async {
      expect(await backend.store().get('nope'), isNull);
    });

    test('storing an id again keeps the first blob', () async {
      final store = backend.store();
      await store.put('p1', photo, contentType: 'image/jpeg');
      await store.put('p1', Uint8List.fromList([9]), contentType: 'image/jpeg');

      expect(await backend.store().get('p1'), photo);
    });

    test('rejects ids that are not safe file names', () async {
      final store = backend.store();
      for (final id in ['', '../x', 'a/b', '.hidden', 'x' * 129]) {
        await expectLater(
          store.put(id, photo, contentType: 'image/jpeg'),
          throwsA(isA<InvalidBlobId>()),
          reason: id,
        );
        await expectLater(
          store.get(id),
          throwsA(isA<InvalidBlobId>()),
          reason: id,
        );
      }
    });
  });
}
