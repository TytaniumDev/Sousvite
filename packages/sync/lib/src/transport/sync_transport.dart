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
/// history, and transports may prune the changes it covers
/// (ENGINEERING.md §8.1, compaction).
@immutable
final class const Snapshot({
  /// The winning change of every field in the space.
  required final List<Change> changes,

  /// The latest timestamp the device that wrote it had seen.
  required final Hlc through,
});

/// One batch of pulled changes, and the cursor that resumes after it.
typedef PulledBatch = ({List<Change> changes, SyncCursor cursor});

/// Carries one space's change log between devices (ENGINEERING.md §8.2).
///
/// Google Drive and Firestore implement it. SYN-3 adds the shared contract
/// test suite that every implementation passes.
abstract interface class SyncTransport() {
  /// Sends [changes] to other devices. Sending a change twice is harmless.
  Future<void> push(List<Change> changes);

  /// Every change after [since], in batches, oldest first. With no cursor,
  /// starts with the latest snapshot's changes. Each batch carries the
  /// cursor to resume after it, so an interrupted pull loses nothing.
  Stream<PulledBatch> pull({SyncCursor? since});

  /// Stores [snapshot] as the space's latest state.
  Future<void> writeSnapshot(Snapshot snapshot);
}
