import 'dart:typed_data';

import 'package:sync/sync.dart';

/// A bucket in memory that, like `storage.rules`, refuses to replace an
/// object.
final class FakeCloudFiles() implements CloudFiles {
  /// Objects by path.
  final objects = <String, Uint8List>{};

  /// Content types by path.
  final contentTypes = <String, String>{};

  @override
  Future<bool> exists(String path) async => objects.containsKey(path);

  @override
  Future<void> upload(
    String path,
    Uint8List bytes, {
    required String contentType,
  }) async {
    if (objects.containsKey(path)) {
      throw StateError('Rules refuse replacing $path');
    }
    objects[path] = bytes;
    contentTypes[path] = contentType;
  }

  @override
  Future<Uint8List?> download(String path) async => objects[path];
}
