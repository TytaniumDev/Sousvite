import 'package:sync/sync.dart';

/// A device's database held in memory.
final class FakeLocalStore(
  /// This device's clock; [write] stamps local changes with it.
  final HybridLogicalClock clock,
) implements LocalStore {
  final winners = <FieldKey, Change>{};
  final log = <Change>[];
  final history = <Change>[];
  final _progress = <String, SyncProgress>{};
  var _sequence = 0;

  /// When set, the next [applyRemote] throws, as if the app were killed.
  bool failNextApply = false;

  /// A local edit, as a repository would record it.
  Change write(
    String field,
    Object? value, {
    String entityId = 'r1',
    String spaceId = 'private',
  }) {
    final change = Change(
      id: '${clock.nodeId}-${_sequence++}',
      entity: 'recipe',
      entityId: entityId,
      field: field,
      value: value,
      hlc: clock.tick(),
      deviceId: clock.nodeId,
      spaceId: spaceId,
    );
    winners[change.key] = change;
    log.add(change);
    return change;
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) => action();

  @override
  Future<List<Change>> ownChangesAfter(
    Hlc? after, {
    required String spaceId,
  }) async =>
      log
          .where(
            (change) =>
                change.deviceId == clock.nodeId &&
                change.spaceId == spaceId &&
                (after == null || change.hlc > after),
          )
          .toList()
        ..sort((a, b) => a.hlc.compareTo(b.hlc));

  @override
  Future<Map<FieldKey, Change>> winnersFor(Set<FieldKey> keys) async => {
    for (final key in keys) key: ?winners[key],
  };

  @override
  Future<List<Change>> allWinners({required String spaceId}) async => [
    for (final change in winners.values)
      if (change.spaceId == spaceId) change,
  ];

  @override
  Future<void> applyRemote({
    required List<Change> winners,
    required List<Change> preserved,
  }) async {
    if (failNextApply) {
      failNextApply = false;
      throw StateError('killed');
    }
    for (final change in winners) {
      this.winners[change.key] = change;
      if (!log.contains(change)) log.add(change);
    }
    history.addAll(preserved);
  }

  @override
  Future<SyncProgress> progress(String transportKey) async =>
      _progress[transportKey] ?? const SyncProgress();

  @override
  Future<void> saveProgress(String transportKey, SyncProgress progress) async =>
      _progress[transportKey] = progress;
}

/// A shared change log held in memory, standing in for Drive or Firestore.
///
/// Cursors are positions in the log. A pull without a cursor starts with
/// the latest snapshot. Pulls come in batches of [batchSize].
final class FakeTransport({final int batchSize = 3}) implements SyncTransport {
  final log = <Change>[];
  Snapshot? snapshot;
  final _ids = <String>{};

  @override
  Future<void> push(List<Change> changes) async {
    for (final change in changes) {
      if (_ids.add(change.id)) log.add(change);
    }
  }

  @override
  Stream<PulledBatch> pull({SyncCursor? since}) async* {
    var position = 0;
    if (since == null) {
      final changes = snapshot?.changes ?? const <Change>[];
      for (var i = 0; i < changes.length; i += batchSize) {
        yield (
          changes: changes.skip(i).take(batchSize).toList(),
          cursor: const SyncCursor('0'),
        );
      }
    } else {
      position = int.parse(since.value);
    }
    while (position < log.length) {
      final batch = log.skip(position).take(batchSize).toList();
      position += batch.length;
      yield (changes: batch, cursor: SyncCursor('$position'));
    }
  }

  @override
  Future<void> writeSnapshot(Snapshot snapshot) async =>
      this.snapshot = snapshot;
}
