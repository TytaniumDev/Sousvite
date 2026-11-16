import 'package:data/data.dart';
import 'package:drift/native.dart';
import 'package:sync/sync.dart';

/// One simulated device for repository tests: an in-memory database, a
/// change recorder, and a sync engine over a shared in-memory space.
///
/// Subclasses add a repository and return its [appliers].
abstract class TestDevice(
  /// The device id, stamped on its changes.
  final String id,

  /// The space every device in a test syncs through.
  final InMemorySyncSpace space,
) {
  /// The device's database.
  final database = AppDatabase(NativeDatabase.memory());

  /// The wall clock in milliseconds; each read moves it on.
  int time = 1000;

  var _ids = 0;

  /// The appliers of the device's repositories, for the sync store.
  Map<String, EntityApplier> get appliers;

  /// The device's clock.
  late final clock = HybridLogicalClock(id, wallClock: () => time++);

  /// Records the device's local writes.
  late final recorder = ChangeRecorder(
    database,
    clock: clock,
    spaceId: 'private',
    newId: () => '$id-${_ids++}',
  );

  /// Syncs the device through [space].
  late final engine = SyncEngine(
    store: DriftLocalStore(database, deviceId: id, appliers: appliers),
    transport: InMemoryTransport(space),
    clock: clock,
    transportKey: 'memory',
    spaceId: 'private',
  );

  /// Every change in the change log, oldest first.
  Future<List<Change>> changes() async => [
    for (final row in await database.syncDao.changesAfter(null)) row.toChange(),
  ];

  /// Ids of the entities with a winning tombstone in the change log.
  Future<Set<String>> tombstones() async => {
    for (final change in await changes())
      if (change.isTombstone) change.entityId,
  };
}
