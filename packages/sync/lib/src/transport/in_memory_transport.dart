import 'package:sync/src/core/change.dart';
import 'package:sync/src/transport/sync_transport.dart';

/// One space's change log and latest snapshot, held in memory and shared
/// by every [InMemoryTransport] made for it.
///
/// A reference for the real transports and a stand-in for them in tests.
/// Writing a snapshot prunes the oldest changes it covers, the way Drive
/// and Firestore compact (ENGINEERING.md §8.1).
final class InMemorySyncSpace() {
  final _log = <Change>[];
  final _ids = <String>{};

  /// How many changes have been pruned from the front of the log. Log
  /// positions stay absolute, so cursors survive pruning.
  var _pruned = 0;
  Snapshot? _snapshot;

  /// Changes still in the log, oldest first.
  List<Change> get changes => List.unmodifiable(_log);

  /// The latest snapshot, if one was written.
  Snapshot? get snapshot => _snapshot;

  void _append(Change change) {
    if (_ids.add(change.id)) _log.add(change);
  }

  void _storeSnapshot(Snapshot snapshot) {
    _snapshot = snapshot;
    final covered = {
      for (final change in snapshot.changes) change.key: change.hlc,
    };
    while (_log.isNotEmpty) {
      final oldest = _log.first;
      final winner = covered[oldest.key];
      if (winner == null || oldest.hlc > winner) break;
      _log.removeAt(0);
      _pruned++;
    }
  }
}

/// A [SyncTransport] over an [InMemorySyncSpace].
///
/// Cursors are positions in the space's log. A pull with no cursor, or
/// with one from before the pruned part of the log, starts with the
/// snapshot as one batch.
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
    var position = since == null ? -1 : int.parse(since.value);
    if (position < space._pruned) {
      position = space._pruned;
      final snapshot = space._snapshot;
      if (snapshot != null) {
        yield (changes: snapshot.changes, cursor: SyncCursor('$position'));
      }
    }
    while (position < space._pruned + space._log.length) {
      final batch = space._log
          .skip(position - space._pruned)
          .take(batchSize)
          .toList();
      position += batch.length;
      yield (changes: batch, cursor: SyncCursor('$position'));
    }
  }

  @override
  Future<void> writeSnapshot(Snapshot snapshot) async =>
      space._storeSnapshot(snapshot);
}
