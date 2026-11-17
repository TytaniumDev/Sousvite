import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/account/sync/data/cloud_firestore_space.dart';
import 'package:sync/sync.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage storage;

  CloudFirestoreSpace space({String spaceId = 'u_alice'}) =>
      CloudFirestoreSpace(
        firestore: firestore,
        storage: storage,
        uid: 'alice',
        spaceId: spaceId,
      );

  setUp(() {
    firestore = FakeFirebaseFirestore();
    storage = MockFirebaseStorage();
  });

  group(CloudFirestoreSpace, () {
    test('creates the profile and private space once', () async {
      await space().ensureExists();
      await space().ensureExists();

      final profile = await firestore.doc('users/alice').get();
      final private = await firestore.doc('spaces/u_alice').get();
      expect(profile.data()?['privateSpaceId'], 'u_alice');
      expect(private.data()?['kind'], 'private');
      expect(private.data()?['memberUids'], ['alice']);
    });

    test('leaves shared spaces to the sharing functions', () async {
      await space(spaceId: 's_1').ensureExists();

      expect((await firestore.doc('spaces/s_1').get()).exists, isFalse);
      expect((await firestore.doc('users/alice').get()).exists, isFalse);
    });

    test('adds batches with the uid and reads them back in order', () async {
      final alice = space();
      for (var i = 0; i < 3; i++) {
        // The fake stamps the wall clock and doesn't break ties by id.
        await Future<void>.delayed(const Duration(milliseconds: 2));
        await alice.addBatch(
          BatchDocument(
            deviceId: 'phone',
            hlcMax: 'h$i',
            changes: [
              {'id': 'c$i'},
            ],
          ),
        );
      }

      final stored = await firestore.collection('spaces/u_alice/batches').get();
      expect(
        stored.docs.map((doc) => doc.data()['uid']),
        everyElement('alice'),
      );

      final first = await alice.batchesAfter(null, limit: 2);
      expect(first, hasLength(2));
      final rest = await alice.batchesAfter(first.last.position, limit: 2);
      expect(
        [...first, ...rest].map((batch) => batch.changes.single['id']).toSet(),
        {'c0', 'c1', 'c2'},
      );
    });

    test('resumes by time when the last batch read is gone', () async {
      final alice = space();
      await alice.addBatch(
        const BatchDocument(deviceId: 'phone', hlcMax: 'h', changes: [{}]),
      );
      final first = (await alice.batchesAfter(null, limit: 1)).single;

      final after = await alice.batchesAfter((
        pushedAtMicros: first.position.pushedAtMicros,
        id: 'gone',
      ), limit: 5);

      expect(after, isEmpty);
    });

    test('reports new batches', () async {
      final alice = space();
      final events = <void>[];
      final subscription = alice.watchNewestBatch().listen(events.add);
      await pumpEventQueue();

      await alice.addBatch(
        const BatchDocument(deviceId: 'phone', hlcMax: 'h', changes: [{}]),
      );
      await pumpEventQueue();

      expect(events.length, greaterThanOrEqualTo(2));
      await subscription.cancel();
    });

    test('stores snapshots in Storage and points the space at them', () async {
      final alice = space();
      await alice.ensureExists();
      expect(await alice.latestSnapshot(), isNull);

      await alice.saveSnapshot(
        'h.json.gz',
        Uint8List.fromList([1, 2, 3]),
        hlc: 'h',
      );

      final pointer = await alice.latestSnapshot();
      expect(pointer, (path: 'spaces/u_alice/snapshots/h.json.gz', hlc: 'h'));
      expect(await alice.readSnapshot(pointer!.path), [1, 2, 3]);
    });

    test('converts server times to whole microseconds and back', () {
      final timestamp = Timestamp(1700000000, 123456789);

      final micros = CloudFirestoreSpace.microsOf(timestamp);

      expect(micros, 1700000000123456);
      expect(
        CloudFirestoreSpace.timestampOf(micros),
        Timestamp(1700000000, 123456000),
      );
    });
  });
}
