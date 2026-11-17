import 'package:flutter/foundation.dart';

/// Where sync stands, for the status icon (ENGINEERING.md §8.2).
enum SyncPhase() {
  /// Signed out, or this build has no cloud: nothing to sync.
  off,

  /// Changes are being sent or received.
  syncing,

  /// Everything on this device is in the cloud.
  synced,

  /// No connection. Changes wait on the device, which is not an error.
  offline,

  /// Google needs the user to tap through again before Drive syncs.
  signInAgain,

  /// The last sync failed for another reason; it is tried again later.
  error,
}

/// What sync is doing now, and when it last finished.
@immutable
final class const SyncState({
  required final SyncPhase phase,

  /// When the last sync finished, or null before the first.
  final DateTime? lastSyncedAt,
}) {
  /// A copy in [phase], keeping [lastSyncedAt] unless given.
  SyncState to(SyncPhase phase, {DateTime? lastSyncedAt}) =>
      SyncState(phase: phase, lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt);

  @override
  bool operator ==(Object other) =>
      other is SyncState &&
      other.phase == phase &&
      other.lastSyncedAt == lastSyncedAt;

  @override
  int get hashCode => Object.hash(phase, lastSyncedAt);
}
