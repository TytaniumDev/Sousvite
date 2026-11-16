import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/cooking/application/screen_awake.dart';

/// Keeps the screen on while [child] is showing, and lets it turn off
/// again when it goes.
class const KeepScreenOn({
  /// What is showing while the screen stays on.
  required final Widget child,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<KeepScreenOn> createState() => _KeepScreenOnState();
}

class _KeepScreenOnState() extends ConsumerState<KeepScreenOn> {
  late final ScreenAwake _screen = ref.read(screenAwakeProvider);

  @override
  void initState() {
    super.initState();
    unawaited(_screen.keepOn());
  }

  @override
  void dispose() {
    unawaited(_screen.release());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
