import 'package:sousvite/l10n/l10n.dart';

/// Durations written the way people say them.
extension DurationLabel on AppLocalizations {
  /// [time] as "45 min", "1 h", or "1 h 30 min". Rounds up to the next
  /// minute, so a recipe never looks shorter than it is.
  String durationLabel(Duration time) {
    final totalMinutes = (time.inSeconds / Duration.secondsPerMinute).ceil();
    final hours = totalMinutes ~/ Duration.minutesPerHour;
    final minutes = totalMinutes % Duration.minutesPerHour;
    if (hours == 0) return common_minutes(minutes);
    if (minutes == 0) return common_hours(hours);
    return common_hoursMinutes(hours, minutes);
  }
}
