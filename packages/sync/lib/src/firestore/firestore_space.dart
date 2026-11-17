// coverage:ignore-file
// Only declares the Firestore port and its value types; the transport
// tests exercise them through an in-memory fake, and the app implements
// the port over cloud_firestore and firebase_storage.

import 'dart:typed_data';

import 'package:meta/meta.dart';

/// Where a batch sits in a space's log: the server time it was pushed, in
/// microseconds since the epoch, then its document id. Pulls read in this
/// order (ENGINEERING.md §9.1). Plain integers, so web keeps the server's
/// full precision.
typedef BatchPosition = ({int pushedAtMicros, String id});

/// One push, as a new document in `spaces/{spaceId}/batches`.
@immutable
final class const BatchDocument({
  /// The device that pushed it.
  required final String deviceId,

  /// The highest HLC of its changes, packed.
  required final String hlcMax,

  /// The changes, as `Change.toJson` maps.
  required final List<Map<String, Object?>> changes,
});

/// A batch read back from the server, with the time the server stamped.
typedef StoredBatch = ({
  BatchPosition position,
  List<Map<String, Object?>> changes,
});

/// The space document's pointer to its latest snapshot file
/// (`latestSnapshot` in ENGINEERING.md §9.1).
typedef SnapshotPointer = ({String path, String hlc});

/// One space in Sousvite cloud, as the Firestore transport needs it: its
/// batches in Firestore and its snapshot files in Cloud Storage
/// (ENGINEERING.md §9.1).
///
/// A port, so `packages/sync` stays pure Dart: the app implements it over
/// `cloud_firestore` and `firebase_storage` for one space id, and tests use
/// an in-memory fake. It adds the signed-in user's uid and the server
/// timestamp that the security rules require.
abstract interface class FirestoreSpace() {
  /// Creates the space document and the user's profile when they are
  /// missing, such as the private space on first sign-in.
  Future<void> ensureExists();

  /// Writes [batch] as a new document with a new id, stamped with the
  /// server time.
  Future<void> addBatch(BatchDocument batch);

  /// Up to [limit] batches after [after] (from the start when null), in
  /// pull order.
  Future<List<StoredBatch>> batchesAfter(
    BatchPosition? after, {
    required int limit,
  });

  /// Emits whenever the newest batch changes, including once on listen.
  Stream<void> watchNewestBatch();

  /// The space's latest snapshot, or null before the first one.
  Future<SnapshotPointer?> latestSnapshot();

  /// Uploads [bytes] as the snapshot file named [name], then points the
  /// space document at it.
  Future<void> saveSnapshot(
    String name,
    Uint8List bytes, {
    required String hlc,
  });

  /// The bytes of the snapshot file at [path].
  Future<Uint8List> readSnapshot(String path);
}
