import 'dart:typed_data';

import 'package:sync/sync.dart';
import 'package:test/test.dart';

import '../../contract/blob_store_contract.dart';
import '../../helpers/fake_drive_app_folder.dart';

final class _DriveHarness() implements BlobHarness {
  final drive = FakeDrive();

  @override
  BlobStore store() => DriveBlobStore(FakeDriveAppFolder(drive));
}

void main() {
  runBlobStoreContract('Drive', _DriveHarness.new);

  group(DriveBlobStore, () {
    test('stores photos under photos/ and waits out rate limits', () async {
      final drive = FakeDrive()..rateLimitedCalls = 2;
      final waits = <Duration>[];
      final store = DriveBlobStore(
        FakeDriveAppFolder(drive),
        retry: DriveRetry(wait: (duration) async => waits.add(duration)),
      );

      await store.put('p1', Uint8List(1), contentType: 'image/jpeg');

      expect(drive.files.single.name, 'photos/p1');
      expect(waits, const [Duration(seconds: 1), Duration(seconds: 2)]);
    });
  });
}
