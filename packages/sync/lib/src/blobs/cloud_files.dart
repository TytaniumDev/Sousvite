// coverage:ignore-file
// Only declares the Cloud Storage port; the blob store tests exercise it
// through an in-memory fake, and the app implements it over
// firebase_storage.

import 'dart:typed_data';

/// The Sousvite cloud bucket, as the cloud blob store needs it.
///
/// A port, so `packages/sync` stays pure Dart: the app implements it over
/// `firebase_storage`, and tests use an in-memory fake. Paths are full
/// object paths, such as `spaces/u_abc/photos/p1`.
abstract interface class CloudFiles() {
  /// Whether an object exists at [path].
  Future<bool> exists(String path);

  /// Uploads [bytes] to [path], typed [contentType].
  Future<void> upload(
    String path,
    Uint8List bytes, {
    required String contentType,
  });

  /// The object at [path], or null when there is none.
  Future<Uint8List?> download(String path);
}
