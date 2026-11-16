/// A time as Umami writes it, such as "1 hour 30 minutes" or "1 day 20
/// minutes". A bare number is minutes. Null when [text] has no time in it
/// or it is zero.
Duration? parseUmamiDuration(String text) {
  final trimmed = text.trim();
  if (int.tryParse(trimmed) case final minutes?) {
    return minutes > 0 ? Duration(minutes: minutes) : null;
  }
  var total = Duration.zero;
  for (final match in _part.allMatches(trimmed)) {
    final count = int.parse(match[1]!);
    total += switch (match[2]!.toLowerCase()) {
      'day' => Duration(days: count),
      'hour' => Duration(hours: count),
      _ => Duration(minutes: count),
    };
  }
  return total > Duration.zero ? total : null;
}

/// [duration] the way Umami writes it: "2 hours 5 minutes".
String formatUmamiDuration(Duration duration) {
  String part(int count, String unit) =>
      count == 1 ? '1 $unit' : '$count ${unit}s';
  final days = duration.inDays;
  final hours = duration.inHours % 24;
  final minutes = duration.inMinutes % 60;
  return [
    if (days > 0) part(days, 'day'),
    if (hours > 0) part(hours, 'hour'),
    if (minutes > 0 || duration.inMinutes == 0) part(minutes, 'minute'),
  ].join(' ');
}

final _part = RegExp(r'(\d+)\s*(day|hour|minute)s?', caseSensitive: false);
