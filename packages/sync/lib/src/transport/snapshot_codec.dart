import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:sync/src/core/change.dart';
import 'package:sync/src/core/hlc.dart';
import 'package:sync/src/transport/sync_transport.dart';

// Snapshots are stored as gzipped JSON files by both cloud transports
// (ENGINEERING.md §8.2). A snapshot can pass Firestore's 1 MiB document
// limit, so it is always a file.

/// [snapshot] as gzipped JSON bytes.
Uint8List encodeSnapshot(Snapshot snapshot) => const GZipEncoder().encodeBytes(
  utf8.encode(
    jsonEncode({
      'through': snapshot.through.pack(),
      'pulledThrough': snapshot.pulledThrough?.value,
      'changes': [for (final change in snapshot.changes) change.toJson()],
    }),
  ),
);

/// Reads bytes written by [encodeSnapshot].
Snapshot decodeSnapshot(List<int> bytes) {
  final json = jsonDecode(
    utf8.decode(const GZipDecoder().decodeBytes(bytes)),
  ) as Map<String, Object?>;
  final pulledThrough = json['pulledThrough'] as String?;
  return Snapshot(
    through: Hlc.parse(json['through']! as String),
    pulledThrough: pulledThrough == null ? null : SyncCursor(pulledThrough),
    changes: [
      for (final change in json['changes']! as List<Object?>)
        Change.fromJson(change! as Map<String, Object?>),
    ],
  );
}
