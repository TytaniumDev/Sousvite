import 'package:sousvite/features/cooking/application/screen_awake.dart';

/// Records whether the screen is being kept on.
class FakeScreenAwake() implements ScreenAwake {
  /// Whether the screen is kept on right now.
  bool isOn = false;

  @override
  Future<void> keepOn() async => isOn = true;

  @override
  Future<void> release() async => isOn = false;
}
