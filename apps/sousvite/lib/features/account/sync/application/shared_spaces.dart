import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/services/firebase.dart';
import 'package:sousvite/features/account/application/auth_user.dart';
import 'package:sousvite/features/account/sync/data/space_memberships.dart';

part 'shared_spaces.g.dart';

/// Where the app reads which joint shares the user is in, or null in
/// builds without Firebase.
@Riverpod(keepAlive: true)
SpaceMemberships? spaceMemberships(Ref ref) {
  final app = ref.watch(firebaseAppProvider);
  if (app == null) return null;
  return SpaceMemberships(FirebaseFirestore.instanceFor(app: app));
}

/// The joint shares the signed-in user is in, live: joining, starting, or
/// leaving one changes it. Empty while signed out or without Firebase.
@Riverpod(keepAlive: true)
Stream<List<String>> sharedSpaceMemberships(Ref ref) {
  final memberships = ref.watch(spaceMembershipsProvider);
  final uid = ref.watch(authUserProvider).value?.id;
  if (memberships == null || uid == null) return Stream.value(const []);
  return memberships.sharedSpaceIdsOf(uid);
}

/// The joint shares the signed-in user is a member of, by space id. Each
/// one syncs through Sousvite cloud next to the private library
/// (ENGINEERING.md §9.1). Keeps the last known list while offline.
@Riverpod(keepAlive: true)
List<String> sharedSpaceIds(Ref ref) =>
    ref.watch(sharedSpaceMembershipsProvider).value ?? const [];
