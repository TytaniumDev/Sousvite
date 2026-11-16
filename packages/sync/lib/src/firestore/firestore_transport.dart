import 'dart:convert';

import 'package:sync/src/core/change.dart';
import 'package:sync/src/firestore/firestore_space.dart';
import 'package:sync/src/transport/snapshot_codec.dart';
import 'package:sync/src/transport/sync_transport.dart';

/// Syncs one space through Sousvite cloud: Firestore for the change log
/// and Cloud Storage for snapshots (ENGINEERING.md §8.2 and §9.1).
///
/// Each push is one or more batch documents that are never changed or
/// deleted, so the log is a full backup. Cursors are batch positions.
/// The app makes one transport per space: the user's private space and
/// each joint share.
final class FirestoreTransport(
  /// The space on the server.
  final FirestoreSpace space, {

  /// The most batches one page of a pull reads.
  final int pageSize = 50,

  /// The most changes in one batch document.
  final int maxChangesPerBatch = 400,

  /// The most JSON bytes of changes in one batch document, well under
  /// Firestore's 1 MiB document limit.
  final int maxBatchBytes = 800 * 1024,
}) implements LiveSyncTransport {
  Future<void>? _exists;

  /// Creates the space once per transport, and again after a failure.
  Future<void> _ensureExists() async {
    try {
      await (_exists ??= space.ensureExists());
    } on Object {
      _exists = null;
      rethrow;
    }
  }

  @override
  Future<void> push(List<Change> changes) async {
    if (changes.isEmpty) return;
    await _ensureExists();
    for (final batch in _split(changes)) {
      await space.addBatch(
        BatchDocument(
          deviceId: batch.first.deviceId,
          hlcMax: batch
              .map((change) => change.hlc)
              .reduce((a, b) => a > b ? a : b)
              .pack(),
          changes: [for (final change in batch) change.toJson()],
        ),
      );
    }
  }

  /// [changes] in order, cut into batches that each fit in one document.
  Iterable<List<Change>> _split(List<Change> changes) sync* {
    var batch = <Change>[];
    var bytes = 0;
    for (final change in changes) {
      final size = utf8.encode(jsonEncode(change.toJson())).length;
      if (batch.isNotEmpty &&
          (batch.length >= maxChangesPerBatch ||
              bytes + size > maxBatchBytes)) {
        yield batch;
        batch = [];
        bytes = 0;
      }
      batch.add(change);
      bytes += size;
    }
    yield batch;
  }

  @override
  Stream<PulledBatch> pull({SyncCursor? since}) async* {
    var position = _decode(since);
    if (since == null) {
      final pointer = await space.latestSnapshot();
      if (pointer != null) {
        final snapshot = decodeSnapshot(await space.readSnapshot(pointer.path));
        position = _decode(snapshot.pulledThrough);
        yield (
          changes: snapshot.changes,
          cursor: snapshot.pulledThrough ?? _start,
        );
      }
    }
    while (true) {
      final page = await space.batchesAfter(position, limit: pageSize);
      for (final batch in page) {
        position = batch.position;
        yield (
          changes: [for (final json in batch.changes) Change.fromJson(json)],
          cursor: _encode(batch.position),
        );
      }
      if (page.length < pageSize) return;
    }
  }

  @override
  Future<void> writeSnapshot(Snapshot snapshot) async {
    await _ensureExists();
    final hlc = snapshot.through.pack();
    await space.saveSnapshot(
      '$hlc.json.gz',
      encodeSnapshot(snapshot),
      hlc: hlc,
    );
  }

  @override
  Stream<void> remoteChanges() => space.watchNewestBatch();

  /// The cursor before the first batch.
  static const _start = SyncCursor('');

  static SyncCursor _encode(BatchPosition position) =>
      SyncCursor('${position.pushedAtMicros}|${position.id}');

  static BatchPosition? _decode(SyncCursor? cursor) {
    final value = cursor?.value;
    if (value == null || value.isEmpty) return null;
    final split = value.indexOf('|');
    return (
      pushedAtMicros: int.parse(value.substring(0, split)),
      id: value.substring(split + 1),
    );
  }
}
