import 'dart:typed_data';

import 'package:sousvite/shared/photos/photo_store.dart';

/// An in-memory [PhotoStore] for tests.
class FakePhotoStore() implements PhotoStore {
  /// The saved photos, by id.
  final Map<String, Uint8List> photos = {};

  @override
  Future<void> write(String id, Uint8List bytes) async => photos[id] = bytes;

  @override
  Future<Uint8List?> read(String id) async => photos[id];

  @override
  Future<void> delete(String id) async => photos.remove(id);
}
