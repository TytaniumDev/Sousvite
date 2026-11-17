import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:sync/sync.dart';

/// One space in Sousvite cloud over `cloud_firestore` and
/// `firebase_storage`, in the layout of ENGINEERING.md §9.1 and the shape
/// `firestore.rules` and `storage.rules` require.
final class CloudFirestoreSpace({
  required final FirebaseFirestore firestore,
  required final FirebaseStorage storage,

  /// The signed-in user, stamped on every batch.
  required final String uid,

  /// The space on the server, such as `u_<uid>` for the private space.
  required final String spaceId,
}) implements FirestoreSpace {
  /// The server id of [uid]'s private space (ENGINEERING.md §9.1).
  static String privateSpaceIdFor(String uid) => 'u_$uid';

  /// The largest snapshot file [readSnapshot] downloads.
  static const int maxSnapshotBytes = 50 * 1024 * 1024;

  DocumentReference<Map<String, Object?>> get _space =>
      firestore.doc('spaces/$spaceId');

  CollectionReference<Map<String, Object?>> get _batches =>
      _space.collection('batches');

  @override
  Future<void> ensureExists() async {
    // Shared spaces are made by the sharing functions.
    if (spaceId != privateSpaceIdFor(uid)) return;
    final profile = firestore.doc('users/$uid');
    if (!(await profile.get()).exists) {
      await profile.set({
        'privateSpaceId': spaceId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    if (!(await _space.get()).exists) {
      await _space.set({
        'kind': 'private',
        'ownerUid': uid,
        'memberUids': [uid],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> addBatch(BatchDocument batch) => _batches.add({
    'deviceId': batch.deviceId,
    'uid': uid,
    'pushedAt': FieldValue.serverTimestamp(),
    'hlcMax': batch.hlcMax,
    'changes': batch.changes,
  });

  @override
  Future<List<StoredBatch>> batchesAfter(
    BatchPosition? after, {
    required int limit,
  }) async {
    // Firestore orders ties on pushedAt by document id on its own.
    var query = _batches.orderBy('pushedAt');
    if (after != null) {
      final last = await _batches.doc(after.id).get();
      query = last.exists
          ? query.startAfterDocument(last)
          : query.startAfter([timestampOf(after.pushedAtMicros)]);
    }
    // Only the server's copy has the server time on every batch.
    final page = await query
        .limit(limit)
        .get(const GetOptions(source: Source.server));
    return [
      for (final document in page.docs)
        (
          position: (
            pushedAtMicros: microsOf(document.data()['pushedAt']! as Timestamp),
            id: document.id,
          ),
          changes: [
            for (final change in document.data()['changes']! as List<Object?>)
              Map<String, Object?>.from(change! as Map<Object?, Object?>),
          ],
        ),
    ];
  }

  @override
  Stream<void> watchNewestBatch() => _batches
      .orderBy('pushedAt', descending: true)
      .limit(1)
      .snapshots()
      .map((_) {});

  @override
  Future<SnapshotPointer?> latestSnapshot() async {
    final latest = (await _space.get()).data()?['latestSnapshot'];
    if (latest is! Map) return null;
    return (path: latest['path']! as String, hlc: latest['hlc']! as String);
  }

  @override
  Future<void> saveSnapshot(
    String name,
    Uint8List bytes, {
    required String hlc,
  }) async {
    final path = 'spaces/$spaceId/snapshots/$name';
    await storage
        .ref(path)
        .putData(bytes, SettableMetadata(contentType: 'application/gzip'));
    await _space.update({
      'latestSnapshot': {'path': path, 'hlc': hlc},
    });
  }

  @override
  Future<Uint8List> readSnapshot(String path) async {
    final bytes = await storage.ref(path).getData(maxSnapshotBytes);
    if (bytes == null) throw StateError('Snapshot $path is missing');
    return bytes;
  }

  /// [timestamp] in microseconds since the epoch, as plain integers so web
  /// keeps the full precision.
  @visibleForTesting
  static int microsOf(Timestamp timestamp) =>
      timestamp.seconds * 1000000 + timestamp.nanoseconds ~/ 1000;

  /// The [Timestamp] for [micros] microseconds since the epoch.
  @visibleForTesting
  static Timestamp timestampOf(int micros) =>
      Timestamp(micros ~/ 1000000, (micros % 1000000) * 1000);
}
