import 'package:sousvite/l10n/l10n.dart';

/// A recipe's total time as people say it: "45 min", "1 h", "1 h 30 min".
/// Rounds up to the next minute, so a recipe never looks shorter than it
/// is.
String totalTimeLabel(AppLocalizations l10n, Duration time) {
  final totalMinutes = (time.inSeconds / Duration.secondsPerMinute).ceil();
  final hours = totalMinutes ~/ Duration.minutesPerHour;
  final minutes = totalMinutes % Duration.minutesPerHour;
  if (hours == 0) return l10n.library_minutes(minutes);
  if (minutes == 0) return l10n.library_hours(hours);
  return l10n.library_hoursMinutes(hours, minutes);
}
