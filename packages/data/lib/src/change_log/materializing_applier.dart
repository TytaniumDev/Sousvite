import 'package:data/src/app_database.dart';
import 'package:data/src/change_log/entity_applier.dart';
import 'package:data/src/change_log/entity_codec.dart';
import 'package:sync/sync.dart';

/// Applies remote changes to one table by rebuilding the entity from the
/// winning value of each of its fields in the change log.
///
/// The change being applied is already in the change log, so the row is
/// written once every required field has arrived, and removed once the
/// entity's tombstone wins. Repositories create one per entity kind.
final class MaterializingApplier<T>(
  /// The local database, whose change log holds the winners.
  final AppDatabase database, {

  /// Reads the entity from its fields.
  required final EntityCodec<T> codec,

  /// Inserts or replaces the entity's row, without recording a change.
  required final Future<void> Function(T entity) write,

  /// Deletes the entity's row by id, without recording a change.
  required final Future<void> Function(String id) remove,
}) implements EntityApplier {
  @override
  Future<void> apply(Change change) async {
    final fields = await database.syncDao.winningFields(
      entity: codec.entity,
      entityId: change.entityId,
    );
    if (fields[Change.deletedField] == true) {
      await remove(change.entityId);
      return;
    }
    final entity = codec.decode(change.entityId, fields);
    if (entity != null) await write(entity);
  }
}
