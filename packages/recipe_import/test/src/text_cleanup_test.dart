import 'package:recipe_import/src/text_cleanup.dart';
import 'package:test/test.dart';

void main() {
  test('cleanText strips tags, decodes entities, and collapses spaces', () {
    expect(cleanText('  <b>Soft</b> &amp;\n  sweet '), 'Soft & sweet');
    expect(cleanText('plain'), 'plain');
  });

  test('cleanIngredient drops cost notes and doubled parentheses', () {
    expect(
      cleanIngredient(r'2 tsp smoked paprika ($0.20)'),
      '2 tsp smoked paprika',
    );
    expect(cleanIngredient(r'1 lb pasta ($1*)'), '1 lb pasta');
    expect(
      cleanIngredient('4 cloves garlic ((minced))'),
      '4 cloves garlic (minced)',
    );
    expect(cleanIngredient('1 cup milk (whole)'), '1 cup milk (whole)');
  });

  group('parseIsoDuration', () {
    test('reads weeks, days, hours, minutes, and seconds', () {
      expect(
        parseIsoDuration('PT1H30M'),
        const Duration(hours: 1, minutes: 30),
      );
      expect(parseIsoDuration('P1DT2H'), const Duration(hours: 26));
      expect(parseIsoDuration('P1W'), const Duration(days: 7));
      expect(parseIsoDuration('pt90s'), const Duration(seconds: 90));
      expect(parseIsoDuration('PT0.5H'), const Duration(minutes: 30));
    });

    test('is null for zero, years or months, and anything else', () {
      for (final text in [
        null,
        '',
        'PT0S',
        'P0Y0M0DT0H0M0S',
        'P1M',
        '1 hour',
      ]) {
        expect(parseIsoDuration(text), isNull, reason: text);
      }
    });
  });
}
