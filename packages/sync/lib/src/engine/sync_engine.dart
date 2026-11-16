import 'package:sync/src/core/change.dart';
import 'package:sync/src/core/hlc.dart';
import 'package:sync/src/core/merge.dart';
import 'package:sync/src/engine/local_store.dart';
import 'package:sync/src/engine/sync_progress.dart';
import 'package:sync/src/transport/sync_transport.dart';

/// What one [SyncEngine.sync] did.
typedef SyncReport = ({
  /// Local changes sent to the transport.
  int pushed,

  /// Remote changes that won their field and were stored.
  int applied,

  /// Losing long-text edits kept in history.
  int preserved,
});

/// Syncs one space of the local database through one transport
/// (ENGINEERING.md §8).
///
/// Push sends this device's changes since the last push. Pull merges
/// remote changes field by field with [resolve], inside one local
/// transaction per batch, so a local edit made meanwhile is never
/// overwritten by an older remote one. Both resume from the progress the
/// store keeps, so an interrupted sync picks up where it stopped, and
/// seeing a change twice is harmless.
final class SyncEngine({
  /// The device's database.
  required final LocalStore store,

  /// Carries changes to and from other devices.
  required final SyncTransport transport,

  /// This device's clock. Pulled changes move it forward, so later local
  /// edits win over what this device has seen.
  required final HybridLogicalClock clock,

  /// Names this transport and space in the store's progress, such as
  /// `drive` or `firestore:<spaceId>`.
  required final String transportKey,

  /// The space this engine syncs.
  required final String spaceId,

  /// Which fields keep their losing edits in history.
  final MergePolicy policy = const MergePolicy(),
}) {
  /// Pushes, then pulls.
  Future<SyncReport> sync() async {
    final pushed = await push();
    final (:applied, :preserved) = await pull();
    return (pushed: pushed, applied: applied, preserved: preserved);
  }

  /// Sends this device's changes since the last push. Returns how many.
  Future<int> push() async {
    final progress = await store.progress(transportKey);
    final changes = await store.ownChangesAfter(
      progress.pushedThrough,
      spaceId: spaceId,
    );
    if (changes.isEmpty) return 0;
    await transport.push(changes);
    await store.saveProgress(
      transportKey,
      progress.copyWith(pushedThrough: changes.last.hlc),
    );
    return changes.length;
  }

  /// Merges remote changes since the last pull into the store.
  Future<({int applied, int preserved})> pull() async {
    var progress = await store.progress(transportKey);
    var applied = 0;
    var preserved = 0;
    await for (final batch in transport.pull(since: progress.pullCursor)) {
      final merged = await store.transaction(() async {
        final result = await _merge(batch.changes);
        progress = progress.copyWith(pullCursor: batch.cursor);
        await store.saveProgress(transportKey, progress);
        return result;
      });
      applied += merged.applied.length;
      preserved += merged.preserved.length;
    }
    return (applied: applied, preserved: preserved);
  }

  /// Writes the space's current state as a snapshot, so new devices start
  /// from it instead of replaying the whole log. The log itself is kept
  /// forever (ENGINEERING.md §8.1).
  Future<void> writeSnapshot() async {
    final progress = await store.progress(transportKey);
    final winners = await store.allWinners(spaceId: spaceId);
    await transport.writeSnapshot(
      Snapshot(
        changes: winners,
        through: clock.latest,
        pulledThrough: progress.pullCursor,
      ),
    );
    await store.saveProgress(
      _snapshotKey,
      SyncProgress(pushedThrough: Hlc(clock.wallClock(), 0, clock.nodeId)),
    );
  }

  /// Writes a snapshot when this device has made [afterChanges] changes
  /// since its last one, or [after] has passed, or it never wrote one
  /// (ENGINEERING.md §8.1). Returns whether it wrote one. The app calls
  /// this after each sync.
  Future<bool> snapshotIfDue({
    int afterChanges = 200,
    Duration after = const Duration(days: 1),
  }) async {
    final last = (await store.progress(_snapshotKey)).pushedThrough;
    if (last != null &&
        clock.wallClock() - last.millis < after.inMilliseconds) {
      final since = await store.ownChangesAfter(last, spaceId: spaceId);
      if (since.length < afterChanges) return false;
    }
    await writeSnapshot();
    return true;
  }

  /// Where this engine remembers when it last wrote a snapshot: a progress
  /// entry of its own, whose `pushedThrough` holds the wall time.
  String get _snapshotKey => '$transportKey#snapshot';

  /// Copies the space's whole state into this engine's transport, for
  /// switching transports (PRD 7.8): the same change log, nothing to
  /// convert. Later pushes send only newer changes.
  Future<void> replay() async {
    await writeSnapshot();
    final own = await store.ownChangesAfter(null, spaceId: spaceId);
    if (own.isEmpty) return;
    final progress = await store.progress(transportKey);
    await store.saveProgress(
      transportKey,
      progress.copyWith(pushedThrough: own.last.hlc),
    );
  }

  Future<MergeBatch> _merge(List<Change> changes) async {
    for (final change in changes) {
      clock.receive(change.hlc);
    }
    final current = await store.winnersFor({
      for (final change in changes) change.key,
    });
    final merged = mergeAll(current, changes, policy: policy);
    if (merged.applied.isNotEmpty || merged.preserved.isNotEmpty) {
      await store.applyRemote(
        winners: merged.applied,
        preserved: merged.preserved,
      );
    }
    return merged;
  }
}
