import 'package:sousvite/features/account/sync/application/sync_controller.dart';
import 'package:sousvite/features/account/sync/application/sync_source.dart';
import 'package:sousvite/features/account/sync/application/sync_state.dart';

/// What the UI asked of a [FakeSyncController].
final class SyncRequests() {
  /// The sources switched to, in order.
  final switches = <SyncSource>[];

  /// How many times "Sign in again" was tapped.
  int signInAgain = 0;

  /// Thrown by `switchTo` when set.
  Exception? switchError;
}

/// A [SyncController] that starts in [initial] and records requests in
/// [requests].
class FakeSyncController(final SyncState initial, final SyncRequests requests)
    extends SyncController {
  @override
  SyncState build() => initial;

  @override
  Future<void> switchTo(SyncSource source) async {
    requests.switches.add(source);
    if (requests.switchError case final error?) throw error;
  }

  @override
  Future<void> signInAgain() async => requests.signInAgain++;
}
