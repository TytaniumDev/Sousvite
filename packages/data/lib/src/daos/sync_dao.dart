import 'package:data/src/app_database.dart';
import 'package:data/src/tables/sync_tables.dart';
import 'package:drift/drift.dart';

part 'sync_dao.g.dart';

/// Queries for the change log and sync state.
@DriftAccessor(tables: [ChangeLog, SyncState])
class SyncDao(super.attachedDatabase)
    extends DatabaseAccessor<AppDatabase>
    with _$SyncDaoMixin {
  /// Appends [rows] to the change log. A row whose id is already there is
  /// skipped, so recording the same change twice is harmless.
  Future<void> insertChanges(List<ChangeLogCompanion> rows) =>
      batch((batch) => batch.insertAll(changeLog, rows, mode: .insertOrIgnore));

  /// Changes with an HLC after [afterHlc] (all of them when null), oldest
  /// first. Packed HLCs sort as text in time order.
  Future<List<ChangeRow>> changesAfter(String? afterHlc) {
    final query = select(changeLog)
      ..orderBy([(row) => OrderingTerm.asc(row.hlc)]);
    if (afterHlc != null) {
      query.where((row) => row.hlc.isBiggerThanValue(afterHlc));
    }
    return query.get();
  }

  /// The change with the highest HLC for one field of one entity: the
  /// field's current winner. Null when the field has no changes.
  Future<ChangeRow?> latestForField({
    required String entity,
    required String entityId,
    required String field,
  }) =>
      (select(changeLog)
            ..where(
              (row) =>
                  row.entity.equals(entity) &
                  row.entityId.equals(entityId) &
                  row.field.equals(field),
            )
            ..orderBy([(row) => OrderingTerm.desc(row.hlc)])
            ..limit(1))
          .getSingleOrNull();

  /// The highest HLC in the change log, or null when it is empty. Used to
  /// start the clock where it left off after the app restarts.
  Future<String?> latestHlc() {
    final latest = changeLog.hlc.max();
    return (selectOnly(
      changeLog,
    )..addColumns([latest])).map((row) => row.read(latest)).getSingle();
  }

  /// Changes [deviceId] made in [spaceId] with an HLC after [afterHlc] (all
  /// of them when null), oldest first: what this device still has to push.
  Future<List<ChangeRow>> ownChangesAfter(
    String? afterHlc, {
    required String deviceId,
    required String spaceId,
  }) {
    final query = select(changeLog)
      ..where(
        (row) => row.deviceId.equals(deviceId) & row.spaceId.equals(spaceId),
      )
      ..orderBy([(row) => OrderingTerm.asc(row.hlc)]);
    if (afterHlc != null) {
      query.where((row) => row.hlc.isBiggerThanValue(afterHlc));
    }
    return query.get();
  }

  /// The winning change of every field in [spaceId]: the change with the
  /// highest HLC for each entity and field.
  Future<List<ChangeRow>> winnersInSpace(String spaceId) => customSelect(
    'SELECT * FROM change_log AS c WHERE c.space_id = ?1 AND c.hlc = '
    '(SELECT MAX(hlc) FROM change_log WHERE entity = c.entity '
    'AND entity_id = c.entity_id AND field = c.field) '
    'ORDER BY c.hlc',
    variables: [Variable.withString(spaceId)],
    readsFrom: {changeLog},
  ).map((row) => changeLog.map(row.data)).get();

  /// How far the transport called [transportKey] has synced, or null
  /// before its first sync.
  Future<SyncStateRow?> syncStateFor(String transportKey) => (select(
    syncState,
  )..where((row) => row.transportKey.equals(transportKey))).getSingleOrNull();

  /// Saves how far a transport has synced.
  Future<void> saveSyncState(SyncStateCompanion state) =>
      into(syncState).insertOnConflictUpdate(state);
}
