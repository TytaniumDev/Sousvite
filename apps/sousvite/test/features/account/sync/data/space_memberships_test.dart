import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/account/sync/data/space_memberships.dart';

void main() {
  group(SpaceMemberships, () {
    late FakeFirebaseFirestore firestore;

    Future<void> space(String id, String kind, List<String> members) =>
        firestore.doc('spaces/$id').set({'kind': kind, 'memberUids': members});

    setUp(() => firestore = FakeFirebaseFirestore());

    test('lists the shared spaces the user is in, sorted', () async {
      await space('u_alice', 'private', ['alice']);
      await space('s_2', 'shared', ['bob', 'alice']);
      await space('s_1', 'shared', ['alice']);
      await space('s_3', 'shared', ['bob']);

      expect(
        await SpaceMemberships(firestore).sharedSpaceIdsOf('alice').first,
        ['s_1', 's_2'],
      );
    });

    test('updates when the user joins, and only on a change', () async {
      final ids = SpaceMemberships(firestore).sharedSpaceIdsOf('alice');
      final seen = expectLater(
        ids,
        emitsInOrder([
          <String>[],
          ['s_1'],
        ]),
      );
      await pumpEventQueue();

      await space('s_9', 'shared', ['bob']);
      await pumpEventQueue();
      await space('s_1', 'shared', ['bob', 'alice']);

      await seen;
    });
  });
}
