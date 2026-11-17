import 'dart:typed_data';

import 'package:sync/src/blobs/blob_store.dart';
import 'package:sync/src/blobs/invalid_blob_id.dart';

/// A [BlobStore] in memory: a reference for the real stores and a
/// stand-in for them in tests.
final class InMemoryBlobStore() implements BlobStore {
  final _blobs = <String, Uint8List>{};

  @override
  Future<void> put(
    String id,
    Uint8List bytes, {
    required String contentType,
  }) async {
    InvalidBlobId.check(id);
    _blobs.putIfAbsent(id, () => Uint8List.fromList(bytes));
  }

  @override
  Future<Uint8List?> get(String id) async {
    InvalidBlobId.check(id);
    return _blobs[id];
  }
}
