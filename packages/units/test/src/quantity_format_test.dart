import 'package:test/test.dart';
import 'package:units/units.dart';

void main() {
  group('QuantityFormat', () {
    test('formats whole numbers plainly', () {
      expect(Quantity.zero.format(), '0');
      expect(Quantity(12).format(), '12');
    });

    test('uses a glyph for every fraction our font has', () {
      final table = {
        Quantity(1, 2): '½',
        Quantity(1, 3): '⅓',
        Quantity(2, 3): '⅔',
        Quantity(1, 4): '¼',
        Quantity(3, 4): '¾',
        Quantity(1, 8): '⅛',
        Quantity(3, 8): '⅜',
        Quantity(5, 8): '⅝',
        Quantity(7, 8): '⅞',
      };
      for (final MapEntry(key: quantity, value: text) in table.entries) {
        expect(quantity.format(), text, reason: '$quantity');
      }
    });

    test('puts a space between the whole part and the fraction', () {
      expect(Quantity(3, 2).format(), '1 ½');
      expect(Quantity(11, 4).format(), '2 ¾');
    });

    test('falls back to a slash for fractions without a glyph', () {
      expect(Quantity(5, 16).format(), '5/16');
      expect(Quantity(6, 5).format(), '1 1/5');
    });

    test('formats negative quantities with a minus sign', () {
      expect(Quantity(-3, 2).format(), '−1 ½');
      expect(Quantity(-2).format(), '−2');
    });
  });
}
