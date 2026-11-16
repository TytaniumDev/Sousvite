import 'package:recipe_import/src/umami/umami_duration.dart';
import 'package:test/test.dart';

void main() {
  group('parseUmamiDuration', () {
    test('reads days, hours, and minutes', () {
      expect(parseUmamiDuration('30 minutes'), const Duration(minutes: 30));
      expect(parseUmamiDuration('1 minute'), const Duration(minutes: 1));
      expect(
        parseUmamiDuration('2 hours 30 minutes'),
        const Duration(hours: 2, minutes: 30),
      );
      expect(parseUmamiDuration('1 hour'), const Duration(hours: 1));
      expect(
        parseUmamiDuration('1 day 20 minutes'),
        const Duration(days: 1, minutes: 20),
      );
    });

    test('reads a bare number as minutes', () {
      expect(parseUmamiDuration(' 45 '), const Duration(minutes: 45));
    });

    test('is null for zero and for text without a time', () {
      for (final text in ['0', '0 minutes', '', 'a while']) {
        expect(parseUmamiDuration(text), isNull, reason: text);
      }
    });
  });

  test('formatUmamiDuration writes what parseUmamiDuration reads', () {
    for (final (duration, text) in [
      (const Duration(minutes: 1), '1 minute'),
      (const Duration(hours: 2, minutes: 5), '2 hours 5 minutes'),
      (const Duration(hours: 1), '1 hour'),
      (const Duration(days: 1, minutes: 20), '1 day 20 minutes'),
      (Duration.zero, '0 minutes'),
    ]) {
      expect(formatUmamiDuration(duration), text);
      if (duration > Duration.zero) {
        expect(parseUmamiDuration(text), duration);
      }
    }
  });
}
