import 'dart:typed_data';

import 'package:sync/src/blobs/blob_store.dart';
import 'package:sync/src/blobs/invalid_blob_id.dart';
import 'package:sync/src/drive/drive_app_folder.dart';
import 'package:sync/src/drive/drive_retry.dart';

/// Blobs in the user's Drive app folder, as `photos/{id}`
/// (ENGINEERING.md §8.2), for users who sync through Drive.
final class DriveBlobStore(
  /// The user's app folder.
  final DriveAppFolder folder, {

  /// Retries calls while Drive is rate limiting.
  final DriveRetry retry = const DriveRetry(),
}) implements BlobStore {
  @override
  Future<void> put(
    String id,
    Uint8List bytes, {
    required String contentType,
  }) async {
    final name = _name(id);
    if (await retry(() => folder.find(name)) != null) return;
    await retry(() => folder.create(name, bytes));
  }

  @override
  Future<Uint8List?> get(String id) async {
    final file = await retry(() => folder.find(_name(id)));
    return file == null ? null : await retry(() => folder.read(file.id));
  }

  static String _name(String id) {
    InvalidBlobId.check(id);
    return 'photos/$id';
  }
}
