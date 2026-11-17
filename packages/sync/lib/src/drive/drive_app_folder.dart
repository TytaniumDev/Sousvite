// coverage:ignore-file
// Only declares the Drive port and its value types; the transport tests
// exercise them through an in-memory fake, and the app implements the port
// over the Drive REST API.

import 'dart:typed_data';

/// A file in the app's hidden Drive folder.
typedef DriveFile = ({String id, String name, DateTime createdTime});

/// Drive refused a call because of a rate limit (a 403 `rateLimitExceeded`
/// or a 429). It is never billed and is safe to retry after a pause
/// (ENGINEERING.md §8.2).
final class const DriveRateLimited() implements Exception {
  @override
  String toString() => 'DriveRateLimited';
}

/// The user's hidden `appDataFolder` in Google Drive, as the Drive
/// transport needs it (ENGINEERING.md §8.2).
///
/// A port, so `packages/sync` stays pure Dart: the app implements it over
/// the Drive REST API with the `drive.appdata` scope, and tests use an
/// in-memory fake. Implementations throw [DriveRateLimited] when Drive
/// asks to slow down.
abstract interface class DriveAppFolder() {
  /// Every file in the folder, or only those created after [createdAfter].
  Future<List<DriveFile>> list({DateTime? createdAfter});

  /// The file named exactly [name], or null when there is none.
  Future<DriveFile?> find(String name);

  /// The contents of the file with [fileId].
  Future<Uint8List> read(String fileId);

  /// Creates a file called [name] holding [bytes].
  Future<DriveFile> create(String name, Uint8List bytes);

  /// Replaces the contents of the file with [fileId].
  Future<void> update(String fileId, Uint8List bytes);
}
