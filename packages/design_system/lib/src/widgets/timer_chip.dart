import 'dart:async';
import 'dart:math' as math;

import 'package:clock/clock.dart';
import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/tokens/motion.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// A time found in a step: tap to start, then a live countdown, then a
/// pulse when it is done (DESIGN_SYSTEM.md §9.2, §8.2).
///
/// The feature owns whether a timer is running (so running timers survive
/// step changes) and passes [startedAt]. The countdown ticks inside this
/// widget, so a ticking clock never rebuilds its parent (ENGINEERING.md §5).
/// Sound and vibration when a timer ends are the feature's job.
class const TimerChip({
  /// The time as found in the step: "20 min".
  required final String label,

  /// How long the timer runs.
  required final Duration duration,

  /// Shown once the time is up: "Done".
  required final String doneLabel,

  /// Called when the idle chip is tapped.
  required final VoidCallback onStart,

  /// When the timer was started, or null while it is idle.
  final DateTime? startedAt,

  /// Called when a running or finished chip is tapped, to cancel or
  /// dismiss it. Null leaves it untappable while it runs.
  final VoidCallback? onStop,
  super.key,
}) extends StatefulWidget {
  @override
  State<TimerChip> createState() => _TimerChipState();
}

class _TimerChipState()
    extends State<TimerChip>
    with SingleTickerProviderStateMixin {
  static final _pulseCurve = SpringCurve(AppMotion.spatialFast);

  /// Material's 18 dp chip icon, which would otherwise grow with the text.
  static const _avatarBox = BoxConstraints.tightFor(width: 18, height: 18);

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: _pulseCurve.duration * 3,
  );
  Timer? _timer;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(TimerChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startedAt != widget.startedAt ||
        oldWidget.duration != widget.duration) {
      _sync();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  /// Recomputes [_remaining] and schedules the next tick at the next whole
  /// second, so the countdown changes exactly once a second.
  void _sync() {
    _timer?.cancel();
    _timer = null;
    final startedAt = widget.startedAt;
    if (startedAt == null) {
      _remaining = null;
      _pulse.reset();
      return;
    }
    final left = startedAt.add(widget.duration).difference(clock.now());
    final wasRunning = _remaining != null && _remaining! > Duration.zero;
    _remaining = left.isNegative ? Duration.zero : left;
    if (_remaining! > Duration.zero) {
      final untilNextSecond = Duration(
        microseconds:
            _remaining!.inMicroseconds % Duration.microsecondsPerSecond,
      );
      _timer = Timer(
        untilNextSecond == Duration.zero
            ? const Duration(seconds: 1)
            : untilNextSecond,
        () => setState(_sync),
      );
    } else if (wasRunning) {
      _pulse.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final remaining = _remaining;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final (background, foreground, icon, text, onPressed) = switch (remaining) {
      null => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
        Symbols.timer_rounded,
        widget.label,
        widget.onStart,
      ),
      Duration.zero => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
        Symbols.alarm_rounded,
        widget.doneLabel,
        widget.onStop,
      ),
      final left => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
        Symbols.timer_rounded,
        formatCountdown(left),
        widget.onStop,
      ),
    };
    final chip = ActionChip(
      avatar: Icon(icon, color: foreground, fill: remaining == null ? 0 : 1),
      // The icon keeps its size at large text, and the label adds no space
      // at its end, so the ink pads the content evenly (§6.5).
      avatarBoxConstraints: _avatarBox,
      labelPadding: const EdgeInsetsDirectional.only(start: AppSpacing.space2),
      label: Text(text),
      labelStyle: context.appText.number.copyWith(color: foreground),
      backgroundColor: background,
      disabledColor: background,
      side: BorderSide.none,
      onPressed: onPressed,
    );
    if (reduceMotion) return chip;
    return ScaleTransition(scale: _pulse.drive(_PulseTween()), child: chip);
  }
}

/// Formats a countdown, rounding up to the second: "4:05", "1:02:03".
@visibleForTesting
String formatCountdown(Duration left) {
  final total = (left.inMicroseconds / Duration.microsecondsPerSecond).ceil();
  final hours = total ~/ 3600;
  final minutes = total % 3600 ~/ 60;
  final seconds = (total % 60).toString().padLeft(2, '0');
  if (hours == 0) return '$minutes:$seconds';
  return '$hours:${minutes.toString().padLeft(2, '0')}:$seconds';
}

/// Three quick bumps in scale, back to 1 at the end.
class _PulseTween() extends Animatable<double> {
  static const _peak = 0.08;

  @override
  double transform(double t) => 1 + _peak * math.sin(3 * math.pi * t).abs();
}
