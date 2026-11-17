import 'dart:async';
import 'dart:typed_data';

import 'package:sync/sync.dart';

/// One space's server data, shared by every [FakeFirestoreSpace] made for
/// it, the way devices share Firestore.
final class FakeFirestoreServer() {
  /// Batches in pull order.
  final batches = <({BatchPosition position, BatchDocument document})>[];

  /// Snapshot files by path.
  final files = <String, Uint8List>{};

  /// The space document's snapshot pointer.
  SnapshotPointer? latest;

  /// How many times a space was created.
  int created = 0;

  /// When set, the next [FakeFirestoreSpace.ensureExists] throws.
  bool failNextEnsure = false;

  var _clock = 1700000000000000;
  final _newest = StreamController<void>.broadcast();
}

/// A [FirestoreSpace] over a [FakeFirestoreServer].
final class FakeFirestoreSpace(final FakeFirestoreServer server)
    implements FirestoreSpace {
  @override
  Future<void> ensureExists() async {
    if (server.failNextEnsure) {
      server.failNextEnsure = false;
      throw StateError('offline');
    }
    server.created++;
  }

  @override
  Future<void> addBatch(BatchDocument batch) async {
    // Same server time for every second batch, so ids break ties.
    server._clock += server.batches.length.isEven ? 1 : 0;
    server.batches.add((
      position: (
        pushedAtMicros: server._clock,
        id: 'b${server.batches.length.toString().padLeft(4, '0')}',
      ),
      document: batch,
    ));
    server._newest.add(null);
  }

  @override
  Future<List<StoredBatch>> batchesAfter(
    BatchPosition? after, {
    required int limit,
  }) async => [
    for (final batch in server.batches)
      if (after == null || _compare(batch.position, after) > 0)
        (position: batch.position, changes: batch.document.changes),
  ].take(limit).toList();

  @override
  Stream<void> watchNewestBatch() async* {
    yield null;
    yield* server._newest.stream;
  }

  @override
  Future<SnapshotPointer?> latestSnapshot() async => server.latest;

  @override
  Future<void> saveSnapshot(
    String name,
    Uint8List bytes, {
    required String hlc,
  }) async {
    final path = 'snapshots/$name';
    server.files[path] = bytes;
    server.latest = (path: path, hlc: hlc);
  }

  @override
  Future<Uint8List> readSnapshot(String path) async => server.files[path]!;

  static int _compare(BatchPosition a, BatchPosition b) {
    final byTime = a.pushedAtMicros.compareTo(b.pushedAtMicros);
    return byTime != 0 ? byTime : a.id.compareTo(b.id);
  }
}
