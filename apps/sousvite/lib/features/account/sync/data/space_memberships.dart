import 'package:cloud_firestore/cloud_firestore.dart';

/// The joint shares a user is a member of, from Firestore's `spaces`
/// (ENGINEERING.md §8.3). The rules allow only this query: spaces whose
/// `memberUids` holds the user.
class const SpaceMemberships(final FirebaseFirestore _firestore) {
  /// The ids of the shared spaces [uid] is a member of, sorted, and again
  /// each time that changes. The private space is left out.
  Stream<List<String>> sharedSpaceIdsOf(String uid) => _firestore
      .collection('spaces')
      .where('memberUids', arrayContains: uid)
      .snapshots()
      .map(
        (snapshot) => [
          for (final space in snapshot.docs)
            if (space.data()['kind'] == 'shared') space.id,
        ]..sort(),
      )
      .distinct(const ListEquality<String>().equals);
}
