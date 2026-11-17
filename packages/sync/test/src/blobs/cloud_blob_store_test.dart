import 'dart:typed_data';

import 'package:sync/sync.dart';
import 'package:test/test.dart';

import '../../contract/blob_store_contract.dart';
import '../../helpers/fake_cloud_files.dart';

final class _CloudHarness() implements BlobHarness {
  final files = FakeCloudFiles();

  @override
  BlobStore store() => CloudBlobStore(files, spaceId: 'u_alice');
}

void main() {
  runBlobStoreContract('Cloud Storage', _CloudHarness.new);

  group(CloudBlobStore, () {
    test("stores photos in the space's folder, typed", () async {
      final files = FakeCloudFiles();

      await CloudBlobStore(
        files,
        spaceId: 's_1',
      ).put('p1', Uint8List(1), contentType: 'image/jpeg');

      expect(files.contentTypes, {'spaces/s_1/photos/p1': 'image/jpeg'});
    });

    test("keeps each space's photos apart", () async {
      final files = FakeCloudFiles();
      await CloudBlobStore(
        files,
        spaceId: 's_1',
      ).put('p1', Uint8List(1), contentType: 'image/jpeg');

      expect(await CloudBlobStore(files, spaceId: 's_2').get('p1'), isNull);
    });
  });
}
