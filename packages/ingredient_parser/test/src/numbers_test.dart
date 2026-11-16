import 'package:domain/domain.dart';
import 'package:ingredient_parser/src/numbers.dart';
import 'package:test/test.dart';

void main() {
  group('parseNumber', () {
    final cases = {
      '2': Quantity(2),
      '1/2': Quantity(1, 2),
      '1⁄2': Quantity(1, 2),
      '1 1/2': Quantity(3, 2),
      '1-1/2': Quantity(3, 2),
      '1½': Quantity(3, 2),
      '½': Quantity(1, 2),
      '1.5': Quantity(3, 2),
      '.25': Quantity(1, 4),
      'one': Quantity(1),
      'Twelve': Quantity(12),
      'a dozen': Quantity(12),
      'half  an': Quantity(1, 2),
    };
    for (final MapEntry(key: text, value: expected) in cases.entries) {
      test(text, () {
        expect(parseNumber(text), expected);
      });
    }
  });

  test('numberPattern stops at the end of the number', () {
    final pattern = RegExp('^$numberPattern');

    expect(pattern.firstMatch('100g')![0], '100');
    expect(pattern.firstMatch('1 1/2 cups')![0], '1 1/2');
  });
}
