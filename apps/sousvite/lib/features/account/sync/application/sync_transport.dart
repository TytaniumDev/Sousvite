import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data/data.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/database.dart';
import 'package:sousvite/app/services/auth_service.dart';
import 'package:sousvite/app/services/firebase.dart';
import 'package:sousvite/features/account/application/auth_user.dart';
import 'package:sousvite/features/account/sync/application/shared_spaces.dart';
import 'package:sousvite/features/account/sync/application/sync_source_controller.dart';
import 'package:sousvite/features/account/sync/data/cloud_firestore_space.dart';
import 'package:sousvite/features/account/sync/data/drive_access.dart';
import 'package:sousvite/features/account/sync/data/drive_rest_folder.dart';
import 'package:sync/sync.dart';

part 'sync_transport.g.dart';

/// One space and the transport it syncs through: its local space id, the
/// transport, and the name its progress is saved under.
typedef SpaceTransport = ({
  String spaceId,
  SyncTransport transport,
  String key,
});

/// Access tokens for the user's Drive app folder.
@Riverpod(keepAlive: true)
DriveAccess driveAccess(Ref ref) => GoogleDriveAccess(GoogleSignIn.instance);

/// Makes the Sousvite cloud space [spaceId] on the server, for [uid].
typedef CloudSpaceFactory = FirestoreSpace Function({
  required String uid,
  required String spaceId,
});

/// Sousvite cloud spaces over Firestore and Cloud Storage, or null in
/// builds without Firebase.
@Riverpod(keepAlive: true)
CloudSpaceFactory? cloudSpaces(Ref ref) {
  final app = ref.watch(firebaseAppProvider);
  if (app == null) return null;
  final firestore = FirebaseFirestore.instanceFor(app: app);
  final storage = FirebaseStorage.instanceFor(app: app);
  return ({required uid, required spaceId}) => CloudFirestoreSpace(
    firestore: firestore,
    storage: storage,
    uid: uid,
    spaceId: spaceId,
  );
}

/// The one place the app picks how the library syncs (ENGINEERING.md §10):
/// Sousvite cloud or the user's Google Drive, from the Sync source setting.
/// Null while signed out, in builds without Firebase, or when the chosen
/// source can't be used, as Drive with an Apple account. Nothing else in
/// the app knows which transport is active.
@Riverpod(keepAlive: true)
SpaceTransport? syncTransport(Ref ref) {
  final spaces = ref.watch(cloudSpacesProvider);
  final user = ref.watch(authUserProvider).value;
  if (spaces == null || user == null) return null;
  final source = ref.watch(syncSourceControllerProvider).value;
  if (source == null) return null;
  switch (source) {
    case .cloud:
      return _cloud(
        spaces,
        uid: user.id,
        spaceId: privateSpaceId,
        serverId: CloudFirestoreSpace.privateSpaceIdFor(user.id),
      );
    case .drive:
      if (user.method != SignInMethod.google) return null;
      final client = http.Client();
      ref.onDispose(client.close);
      return (
        spaceId: privateSpaceId,
        transport: DriveTransport(
          DriveRestFolder(
            client: client,
            access: ref.watch(driveAccessProvider),
          ),
          deviceId: ref.watch(changeRecorderProvider).requireValue.clock.nodeId,
        ),
        key: 'drive:${user.id}',
      );
  }
}

/// The joint shares, each syncing through Sousvite cloud whatever the Sync
/// source is. Empty while signed out or in builds without Firebase.
@Riverpod(keepAlive: true)
List<SpaceTransport> sharedSyncTransports(Ref ref) {
  final spaces = ref.watch(cloudSpacesProvider);
  final user = ref.watch(authUserProvider).value;
  if (spaces == null || user == null) return const [];
  return [
    for (final id in ref.watch(sharedSpaceIdsProvider))
      _cloud(spaces, uid: user.id, spaceId: id, serverId: id),
  ];
}

SpaceTransport _cloud(
  CloudSpaceFactory spaces, {
  required String uid,
  required String spaceId,
  required String serverId,
}) => (
  spaceId: spaceId,
  transport: FirestoreTransport(spaces(uid: uid, spaceId: serverId)),
  key: 'firestore:$serverId',
);

/// The device's database as the sync engine sees it, with an applier for
/// every entity kind a repository stores.
@Riverpod(keepAlive: true)
LocalStore syncLocalStore(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  final recorder = ref.watch(changeRecorderProvider).requireValue;
  return DriftLocalStore(
    database,
    deviceId: recorder.clock.nodeId,
    appliers: {
      ...DriftRecipeRepository(database, recorder: recorder).appliers,
      ...DriftFolderRepository(database, recorder: recorder).appliers,
      ...DriftGroceryRepository(database, recorder: recorder).appliers,
      ...DriftFoodRepository(database, recorder: recorder).appliers,
      ...DriftExperimentRepository(
        database,
        recorder: recorder,
        recipes: DriftRecipeRepository(database, recorder: recorder),
      ).appliers,
      ...DriftAppSettingsRepository(database, recorder: recorder).appliers,
      ...DriftMeasuringToolRepository(database, recorder: recorder).appliers,
      ...DriftUserRecipePrefsRepository(database, recorder: recorder).appliers,
    },
  );
}
