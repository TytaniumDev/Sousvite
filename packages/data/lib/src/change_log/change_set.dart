import 'package:collection/collection.dart';
import 'package:data/src/change_log/entity_codec.dart';
import 'package:sync/sync.dart';

/// One field value a write recorded, before it gets a timestamp.
typedef PendingChange = ({
  String entity,
  String entityId,
  String field,
  Object? value,
  String? spaceId,
});

/// The field changes one write makes, collected while the write runs.
///
/// Repositories call [set] for the fields they change and [delete] for the
/// entities they remove. `ChangeRecorder.write` then stamps and stores them
/// in the same transaction as the write.
final class ChangeSet() {
  final _pending = <PendingChange>[];

  /// What has been recorded so far, in order.
  List<PendingChange> get pending => List.unmodifiable(_pending);

  /// Records new values for [fields] of one entity.
  ///
  /// Each value must be JSON-compatible (null, bool, num, String, or lists
  /// and string-keyed maps of those). [spaceId] defaults to the recorder's
  /// space, the user's own library.
  void set(
    String entity,
    String entityId,
    Map<String, Object?> fields, {
    String? spaceId,
  }) {
    for (final MapEntry(key: field, :value) in fields.entries) {
      _pending.add((
        entity: entity,
        entityId: entityId,
        field: field,
        value: value,
        spaceId: spaceId,
      ));
    }
  }

  /// Records that one entity was deleted, as a tombstone.
  void delete(String entity, String entityId, {String? spaceId}) =>
      set(entity, entityId, {Change.deletedField: true}, spaceId: spaceId);

  /// Records the fields of [entity] that differ from [before], or all of
  /// them when [before] is null (a new entity). Unchanged fields are left
  /// out, so saving a whole entity never overwrites another device's edit
  /// to a field this device did not change.
  ///
  /// A new entity also clears its tombstone, so saving one again after a
  /// delete (an undo) brings it back on every device.
  void setChanged<T>(
    EntityCodec<T> codec,
    T entity, {
    T? before,
    String? spaceId,
  }) {
    final fields = codec.encode(entity);
    final old = before == null ? null : codec.encode(before);
    set(codec.entity, codec.idOf(entity), {
      for (final MapEntry(:key, :value) in fields.entries)
        if (old == null || !_equality.equals(old[key], value)) key: value,
      if (old == null) Change.deletedField: false,
    }, spaceId: spaceId);
  }

  static const _equality = DeepCollectionEquality();
}
