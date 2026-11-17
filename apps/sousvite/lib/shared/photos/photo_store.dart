// coverage:ignore-file
// Only declares an interface: its empty primary constructor is the only
// line coverage sees, and it never runs.

import 'dart:typed_data';

/// Recipe photos saved on this device, by id (ENGINEERING.md §7.2).
///
/// Files on iOS and Android, IndexedDB on web. MEDIA-2 syncs them.
abstract interface class PhotoStore() {
  /// Saves [bytes] as the photo [id], replacing any photo with that id.
  Future<void> write(String id, Uint8List bytes);

  /// The photo [id], or null when it isn't on this device.
  Future<Uint8List?> read(String id);

  /// Deletes the photo [id]. Does nothing when it isn't there.
  Future<void> delete(String id);
}
