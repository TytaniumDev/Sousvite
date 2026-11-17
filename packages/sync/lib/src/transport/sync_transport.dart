// coverage:ignore-file
// Only declares the transport interface and its small value types; the
// engine tests exercise them through a fake.

import 'package:meta/meta.dart';
import 'package:sync/src/core/change.dart';
import 'package:sync/src/core/hlc.dart';

/// Where a transport's pull left off. Opaque to the engine: each transport
/// decides what it holds, such as a file index or a Firestore document id.
extension type const SyncCursor(String value);

/// The current state of a space: the winning change of every field.
///
/// New devices start from the latest snapshot instead of replaying all
/// history. A snapshot never replaces the log: transports keep every
/// change forever, so the log stays a full edit-by-edit backup
/// (ENGINEERING.md §8.1).
@immutable
final class const Snapshot({
  /// The winning change of every field in the space.
  required final List<Change> changes,

  /// The latest timestamp the device that wrote it had seen.
  required final Hlc through,

  /// Where the writing device's pulls had reached in this transport, so a
  /// pull that starts from the snapshot resumes the log after it. Null
  /// when the device had not pulled yet, as in `replay()`: the pull then
  /// reads the whole log after the snapshot, which is harmless because
  /// merging is idempotent.
  final SyncCursor? pulledThrough,
});

/// One batch of pulled changes, and the cursor that resumes after it.
typedef PulledBatch = ({List<Change> changes, SyncCursor cursor});

/// Carries one space's change log between devices (ENGINEERING.md §8.2).
///
/// Google Drive and Firestore implement it, and every implementation passes
/// the shared contract suite in `test/contract/`. Changes are never
/// deleted from a transport (ENGINEERING.md §8.1).
abstract interface class SyncTransport() {
  /// Sends [changes] to other devices. Sending a change twice is harmless.
  Future<void> push(List<Change> changes);

  /// Every change after [since], in batches, oldest first. With no cursor,
  /// starts with the latest snapshot's changes, then the log after the
  /// snapshot's [Snapshot.pulledThrough]. Each batch carries the cursor to
  /// resume after it, so an interrupted pull loses nothing.
  Stream<PulledBatch> pull({SyncCursor? since});

  /// Stores [snapshot] as the space's latest state.
  Future<void> writeSnapshot(Snapshot snapshot);
}

/// A transport that can tell when other devices pushed, such as
/// Firestore's realtime listener. The app syncs on each event; transports
/// without it, such as Drive, are polled (ENGINEERING.md §8.2).
abstract interface class LiveSyncTransport() implements SyncTransport {
  /// Emits when changes that this device has not pulled may be waiting.
  /// Listening starts the watch, and cancelling stops it.
  Stream<void> remoteChanges();
}
