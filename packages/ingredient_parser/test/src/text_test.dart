import 'package:ingredient_parser/src/text.dart';
import 'package:test/test.dart';

void main() {
  group('cleanLine', () {
    final cases = {
      '  2  cups flour ': '2 cups flour',
      '• 2 eggs': '2 eggs',
      '1 tbsp honey 🍯': '1 tbsp honey',
      '1 cup⁠ edamame': '1 cup edamame',
      '1 lb chicken – boneless': '1 lb chicken, boneless',
      '1 – 2 teaspoons vanilla': '1 – 2 teaspoons vanilla',
      '1 cup rice (white – or brown)': '1 cup rice (white – or brown)',
    };
    for (final MapEntry(key: line, value: expected) in cases.entries) {
      test(line, () {
        expect(cleanLine(line), expected);
      });
    }
  });

  group('splitAtComma', () {
    test('splits at the first comma', () {
      expect(splitAtComma('onion, diced, rinsed'), ('onion', ' diced, rinsed'));
    });

    test('skips commas in parentheses', () {
      expect(splitAtComma('rice (white, brown), cooked'), (
        'rice (white, brown)',
        ' cooked',
      ));
    });

    test('skips commas between describing words', () {
      expect(splitAtComma('boneless, skinless thighs, cubed'), (
        'boneless, skinless thighs',
        ' cubed',
      ));
    });

    test('returns null when there is no comma', () {
      expect(splitAtComma('salt (to) taste)'), ('salt (to) taste)', null));
    });
  });
}
