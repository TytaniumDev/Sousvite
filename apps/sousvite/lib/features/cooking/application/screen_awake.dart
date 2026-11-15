import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'screen_awake.g.dart';

/// Keeps the screen on while cooking mode is open (DESIGN_SYSTEM.md
/// §10.3). An interface so tests run without the platform plugin.
abstract interface class ScreenAwake() {
  /// Keeps the screen from turning off.
  Future<void> keepOn();

  /// Lets the screen turn off again.
  Future<void> release();
}

/// The screen wake lock.
@riverpod
ScreenAwake screenAwake(Ref ref) => const _WakelockScreenAwake();

// coverage:ignore-start
// Calls the platform plugin, which widget tests replace.
class const _WakelockScreenAwake() implements ScreenAwake {
  @override
  Future<void> keepOn() => WakelockPlus.enable();

  @override
  Future<void> release() => WakelockPlus.disable();
}
// coverage:ignore-end
