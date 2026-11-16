import 'dart:typed_data';

import 'package:sync/sync.dart';

/// One user's Drive app folder, shared by every [FakeDriveAppFolder] made
/// for it, the way devices share the user's Drive.
final class FakeDrive() {
  /// Files in the order they were created.
  final files = <DriveFile>[];

  /// File contents by id.
  final contents = <String, Uint8List>{};

  /// Names of files that listings leave out, as if Drive listed them late.
  final hidden = <String>{};

  /// How many calls throw [DriveRateLimited] before the next one works.
  int rateLimitedCalls = 0;

  /// How many times a listing ran.
  int listings = 0;

  var _clock = DateTime.utc(2026, 11, 16);

  void _maybeThrottle() {
    if (rateLimitedCalls > 0) {
      rateLimitedCalls--;
      throw const DriveRateLimited();
    }
  }
}

/// A [DriveAppFolder] over a [FakeDrive].
final class FakeDriveAppFolder(final FakeDrive drive)
    implements DriveAppFolder {
  @override
  Future<List<DriveFile>> list({DateTime? createdAfter}) async {
    drive._maybeThrottle();
    drive.listings++;
    return [
      for (final file in drive.files)
        if (!drive.hidden.contains(file.name) &&
            (createdAfter == null || file.createdTime.isAfter(createdAfter)))
          file,
    ];
  }

  @override
  Future<DriveFile?> find(String name) async {
    drive._maybeThrottle();
    for (final file in drive.files) {
      if (file.name == name) return file;
    }
    return null;
  }

  @override
  Future<Uint8List> read(String fileId) async {
    drive._maybeThrottle();
    return drive.contents[fileId]!;
  }

  @override
  Future<DriveFile> create(String name, Uint8List bytes) async {
    drive._maybeThrottle();
    drive._clock = drive._clock.add(const Duration(seconds: 1));
    final file = (
      id: 'f${drive.files.length}',
      name: name,
      createdTime: drive._clock,
    );
    drive.files.add(file);
    drive.contents[file.id] = bytes;
    return file;
  }

  @override
  Future<void> update(String fileId, Uint8List bytes) async {
    drive._maybeThrottle();
    drive.contents[fileId] = bytes;
  }
}
