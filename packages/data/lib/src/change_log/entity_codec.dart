// coverage:ignore-file
// Only declares the codec interface; each repository's codecs are tested
// through its own tests.

/// Turns one kind of entity into the field values the change log stores,
/// and back (ENGINEERING.md §8.1).
///
/// Local writes record the fields [encode] returns, and remote changes are
/// turned back into an entity with [decode], so both paths agree on what
/// each field means.
abstract interface class EntityCodec<T>() {
  /// The entity kind in the change log, such as `recipe`.
  String get entity;

  /// The id [value] is stored under.
  String idOf(T value);

  /// Every field of [value] except its id, as JSON-compatible values.
  Map<String, Object?> encode(T value);

  /// The entity with [id] and [fields], or null while a required field is
  /// still missing (sync can deliver an entity's fields one at a time).
  T? decode(String id, Map<String, Object?> fields);
}
