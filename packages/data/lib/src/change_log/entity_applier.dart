// coverage:ignore-file
// Only declares the applier interface; DriftLocalStore's tests exercise it
// through a fake, and each repository task adds a real one.

import 'package:sync/sync.dart';

/// Writes remote changes for one kind of entity into its table, such as a
/// recipe's title into the `recipes` row.
///
/// Each repository (DATA-2 to DATA-7) registers one with
/// `DriftLocalStore`. Changes for an entity with no applier still land in
/// the change log, so its rows can be rebuilt once the applier exists.
abstract interface class EntityApplier() {
  /// Sets [change]'s field on its entity, creating the row if it does not
  /// exist yet (sync can deliver a child before its parent), or removes
  /// the row for a tombstone. Runs inside the sync transaction.
  Future<void> apply(Change change);
}
