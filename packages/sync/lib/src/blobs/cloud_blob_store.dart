import 'dart:typed_data';

import 'package:sync/src/blobs/blob_store.dart';
import 'package:sync/src/blobs/cloud_files.dart';
import 'package:sync/src/blobs/invalid_blob_id.dart';

/// One space's blobs in Cloud Storage, at `spaces/{spaceId}/photos/{id}`
/// (ENGINEERING.md §9.1), for Sousvite cloud and joint shares.
/// `storage.rules` lets only the space's members read and add them.
final class CloudBlobStore(
  /// The bucket.
  final CloudFiles files, {

  /// The space on the server, such as `u_<uid>` or a share's id.
  required final String spaceId,
}) implements BlobStore {
  @override
  Future<void> put(
    String id,
    Uint8List bytes, {
    required String contentType,
  }) async {
    final path = _path(id);
    // Rules allow only creating a photo, never replacing it.
    if (await files.exists(path)) return;
    await files.upload(path, bytes, contentType: contentType);
  }

  @override
  Future<Uint8List?> get(String id) =>
      Future.sync(() => files.download(_path(id)));

  String _path(String id) {
    InvalidBlobId.check(id);
    return 'spaces/$spaceId/photos/$id';
  }
}
