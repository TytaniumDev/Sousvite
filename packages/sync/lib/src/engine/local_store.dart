// coverage:ignore-file
// Only declares the local store interface; the engine tests exercise it
// through a fake, and packages/data implements it over Drift.

import 'package:sync/src/core/change.dart';
import 'package:sync/src/core/hlc.dart';
import 'package:sync/src/engine/sync_progress.dart';

/// The device's own database, as the sync engine sees it.
///
/// `packages/data` implements this over Drift, so the engine never
/// depends on the database (ENGINEERING.md §4.2).
abstract interface class LocalStore() {
  /// Runs [action] in one database transaction.
  Future<T> transaction<T>(Future<T> Function() action);

  /// Changes this device made in [spaceId] with an HLC after [after] (all
  /// of them when null), oldest first.
  Future<List<Change>> ownChangesAfter(Hlc? after, {required String spaceId});

  /// The current winning change of each field in [keys]. Fields with no
  /// changes are left out.
  Future<Map<FieldKey, Change>> winnersFor(Set<FieldKey> keys);

  /// The winning change of every field in [spaceId]: its current state.
  Future<List<Change>> allWinners({required String spaceId});

  /// Stores remote changes that won their field, in order, so the entity
  /// rows show their values, and keeps [preserved] losing long-text edits
  /// in history. Storing a change the store already has is harmless.
  Future<void> applyRemote({
    required List<Change> winners,
    required List<Change> preserved,
  });

  /// How far the transport called [transportKey] has synced.
  Future<SyncProgress> progress(String transportKey);

  /// Saves how far the transport called [transportKey] has synced.
  Future<void> saveProgress(String transportKey, SyncProgress progress);
}
