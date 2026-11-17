import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:sync/sync.dart';

/// The Sousvite cloud bucket over `firebase_storage`, for photos
/// (ENGINEERING.md §9.1).
final class FirebaseCloudFiles(
  /// The app's Cloud Storage.
  final FirebaseStorage storage,
) implements CloudFiles {
  /// The largest photo [download] reads, the limit `storage.rules` sets.
  static const int maxBytes = 10 * 1024 * 1024;

  @override
  Future<bool> exists(String path) async {
    try {
      await storage.ref(path).getMetadata();
      return true;
    } on FirebaseException catch (error) {
      if (_isNotFound(error)) return false;
      rethrow;
    }
  }

  @override
  Future<void> upload(
    String path,
    Uint8List bytes, {
    required String contentType,
  }) async {
    await storage
        .ref(path)
        .putData(bytes, SettableMetadata(contentType: contentType));
  }

  @override
  Future<Uint8List?> download(String path) async {
    try {
      return await storage.ref(path).getData();
    } on FirebaseException catch (error) {
      if (_isNotFound(error)) return null;
      rethrow;
    }
  }

  /// Whether [error] says the object isn't there.
  static bool _isNotFound(FirebaseException error) =>
      error.code == 'object-not-found';
}
