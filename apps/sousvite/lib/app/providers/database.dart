import 'package:clock/clock.dart';
import 'package:data/data.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sync/sync.dart';
import 'package:uuid/uuid.dart';

part 'database.g.dart';

/// The app's one database connection, open for the app's lifetime.
///
/// SQLite on iOS and Android; WebAssembly SQLite on web, using
/// `web/sqlite3.wasm` and `web/drift_worker.js` (ENGINEERING.md §7). Tests
/// override this with `AppDatabase(NativeDatabase.memory())`.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase(
    driftDatabase(
      name: 'sousvite',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ),
  );
  ref.onDispose(database.close);
  return database;
}

/// The space local writes belong to: this user's own library. Shared
/// spaces get their own ids when sharing lands (ENGINEERING.md §8.3).
const privateSpaceId = 'private';

/// Records every local write in the change log for sync.
///
/// Loads this device's id and moves the clock past the last change, so it
/// is async. `bootstrap` waits for it before the first frame, so
/// repositories read it with `requireValue`.
@Riverpod(keepAlive: true)
Future<ChangeRecorder> changeRecorder(Ref ref) async {
  final database = ref.watch(appDatabaseProvider);
  String newId() => const Uuid().v4();
  final recorder = ChangeRecorder(
    database,
    clock: HybridLogicalClock(
      await database.syncDao.deviceId(newId: newId),
      wallClock: () => clock.now().millisecondsSinceEpoch,
    ),
    spaceId: privateSpaceId,
    newId: newId,
  );
  await recorder.resumeClock();
  return recorder;
}
