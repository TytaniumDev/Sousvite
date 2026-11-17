import 'package:data/src/app_database.dart';
import 'package:data/src/change_log/change_row_mapping.dart';
import 'package:data/src/change_log/entity_applier.dart';
import 'package:data/src/daos/sync_dao.dart';
import 'package:drift/drift.dart';
import 'package:sync/sync.dart';

/// The sync engine's [LocalStore] over the Drift database.
///
/// Remote changes go into the change log, and each winner is written to
/// its entity's table by the [EntityApplier] registered for it. Losing
/// long-text edits are stored in the change log too, so they are never
/// lost, and handed to [onPreserved] for the recipe's history.
final class DriftLocalStore(
  /// The local database.
  final AppDatabase database, {

  /// This device's id: changes with it are the ones to push.
  required final String deviceId,

  /// Appliers by entity kind, such as `recipe`.
  final Map<String, EntityApplier> appliers = const {},

  /// Receives losing long-text edits, inside the sync transaction. The
  /// history repository (DATA-5) turns them into history entries.
  final Future<void> Function(List<Change> preserved)? onPreserved,

  /// Reads the wall clock, for the last-synced time. Tests pass a fake.
  final DateTime Function() now = DateTime.now,
}) implements LocalStore {
  SyncDao get _dao => database.syncDao;

  @override
  Future<T> transaction<T>(Future<T> Function() action) =>
      database.transaction(action);

  @override
  Future<List<Change>> ownChangesAfter(
    Hlc? after, {
    required String spaceId,
  }) async => [
    for (final row in await _dao.ownChangesAfter(
      after?.pack(),
      deviceId: deviceId,
      spaceId: spaceId,
    ))
      row.toChange(),
  ];

  @override
  Future<Map<FieldKey, Change>> winnersFor(Set<FieldKey> keys) async {
    final winners = <FieldKey, Change>{};
    for (final key in keys) {
      final row = await _dao.latestForField(
        entity: key.entity,
        entityId: key.entityId,
        field: key.field,
      );
      if (row != null) winners[key] = row.toChange();
    }
    return winners;
  }

  @override
  Future<List<Change>> allWinners({required String spaceId}) async => [
    for (final row in await _dao.winnersInSpace(spaceId)) row.toChange(),
  ];

  @override
  Future<void> applyRemote({
    required List<Change> winners,
    required List<Change> preserved,
  }) async {
    await _dao.insertChanges([
      for (final change in [...winners, ...preserved]) change.toCompanion(),
    ]);
    for (final change in winners) {
      await appliers[change.entity]?.apply(change);
    }
    if (preserved.isNotEmpty) await onPreserved?.call(preserved);
  }

  @override
  Future<SyncProgress> progress(String transportKey) async {
    final row = await _dao.syncStateFor(transportKey);
    final cursor = row?.pullCursor;
    final pushed = row?.pushedThroughHlc;
    return SyncProgress(
      pullCursor: cursor == null ? null : SyncCursor(cursor),
      pushedThrough: pushed == null ? null : Hlc.parse(pushed),
    );
  }

  @override
  Future<void> saveProgress(String transportKey, SyncProgress progress) =>
      _dao.saveSyncState(
        SyncStateCompanion.insert(
          transportKey: transportKey,
          pullCursor: Value(progress.pullCursor?.value),
          pushedThroughHlc: Value(progress.pushedThrough?.pack()),
          lastSyncedAt: Value(now()),
        ),
      );
}
