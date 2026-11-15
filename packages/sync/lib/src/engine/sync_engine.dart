import 'package:sync/src/core/change.dart';
import 'package:sync/src/core/hlc.dart';
import 'package:sync/src/core/merge.dart';
import 'package:sync/src/engine/local_store.dart';
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
  /// from it and the transport can prune older changes. The app calls this
  /// now and then, such as once a day.
  Future<void> writeSnapshot() async {
    final winners = await store.allWinners(spaceId: spaceId);
    await transport.writeSnapshot(
      Snapshot(changes: winners, through: clock.latest),
    );
  }

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
