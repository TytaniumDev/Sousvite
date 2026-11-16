import 'package:domain/domain.dart';
import 'package:nutrition/nutrition.dart';
import 'package:test/test.dart';

void main() {
  group('parseServingText', () {
    test('reads a number and a unit', () {
      expect(parseServingText('1 cup'), const Amount(Quantity.one, Unit.cup));
      expect(parseServingText('2 Tbsp'), Amount(Quantity(2), Unit.tablespoon));
      expect(parseServingText('0.5 CUP'), Amount(Quantity(1, 2), Unit.cup));
      expect(parseServingText('1/4 cup'), Amount(Quantity(1, 4), Unit.cup));
      expect(parseServingText('30g'), Amount(Quantity(30), Unit.gram));
    });

    test('is null for anything else', () {
      for (final text in [
        null,
        '',
        '1 bar',
        'about 8 chips',
        '0 cup',
        '1/0 cup',
      ]) {
        expect(parseServingText(text), isNull, reason: text);
      }
    });
  });
}
