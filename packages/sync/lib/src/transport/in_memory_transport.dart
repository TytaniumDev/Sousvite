import 'package:sync/src/core/change.dart';
import 'package:sync/src/transport/sync_transport.dart';

/// One space's change log and latest snapshot, held in memory and shared
/// by every [InMemoryTransport] made for it.
///
/// A reference for the real transports and a stand-in for them in tests.
/// Like them, it keeps every change forever: a snapshot only lets new
/// devices start fast (ENGINEERING.md §8.1).
final class InMemorySyncSpace() {
  final _log = <Change>[];
  final _ids = <String>{};
  Snapshot? _snapshot;

  /// Every change pushed, oldest first.
  List<Change> get changes => List.unmodifiable(_log);

  /// The latest snapshot, if one was written.
  Snapshot? get snapshot => _snapshot;

  void _append(Change change) {
    if (_ids.add(change.id)) _log.add(change);
  }
}

/// A [SyncTransport] over an [InMemorySyncSpace].
///
/// Cursors are positions in the space's log. A pull with no cursor starts
/// with the snapshot as one batch, then reads the log from the snapshot's
/// cursor.
final class InMemoryTransport(
  /// The space this transport syncs.
  final InMemorySyncSpace space, {

  /// The most changes in one pulled batch.
  final int batchSize = 100,
}) implements SyncTransport {
  @override
  Future<void> push(List<Change> changes) async =>
      changes.forEach(space._append);

  @override
  Stream<PulledBatch> pull({SyncCursor? since}) async* {
    var position = 0;
    if (since != null) {
      position = int.parse(since.value);
    } else if (space._snapshot case final snapshot?) {
      position = int.parse(snapshot.pulledThrough?.value ?? '0');
      yield (changes: snapshot.changes, cursor: SyncCursor('$position'));
    }
    while (position < space._log.length) {
      final batch = space._log.skip(position).take(batchSize).toList();
      position += batch.length;
      yield (changes: batch, cursor: SyncCursor('$position'));
    }
  }

  @override
  Future<void> writeSnapshot(Snapshot snapshot) async =>
      space._snapshot = snapshot;
}
