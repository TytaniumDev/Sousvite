// coverage:ignore-file
// Only declares an interface: its empty primary constructor is the only
// line coverage sees, and it never runs.

import 'dart:typed_data';

/// Files a space syncs beside its change log, such as recipe photos, by id
/// (ENGINEERING.md §7.2 and §9.1).
///
/// A blob never changes once stored: a new photo gets a new id. So storing
/// an id that is already there does nothing, and blobs are never deleted
/// by sync, since recipe history can still point at them.
abstract interface class BlobStore() {
  /// Stores [bytes] as the blob [id], typed [contentType] (such as
  /// `image/jpeg`). Does nothing when [id] is already stored.
  Future<void> put(String id, Uint8List bytes, {required String contentType});

  /// The blob [id], or null when it isn't stored (yet).
  Future<Uint8List?> get(String id);
}
