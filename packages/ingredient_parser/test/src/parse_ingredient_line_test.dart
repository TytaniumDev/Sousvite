import 'package:domain/domain.dart';
import 'package:ingredient_parser/ingredient_parser.dart';
import 'package:test/test.dart';

/// Most cases are in the corpus (test/fixtures); these show the API.
void main() {
  group('parseIngredientLine', () {
    test('splits amount, unit, name, and preparation', () {
      expect(
        parseIngredientLine('1 ½ cups rolled oats, chopped'),
        ParsedLine(
          text: '1 ½ cups rolled oats, chopped',
          quantity: Quantity(3, 2),
          unit: .cup,
          name: 'rolled oats',
          preparation: 'chopped',
        ),
      );
    });

    test('keeps the line as written', () {
      expect(parseIngredientLine('  2  eggs ').text, '  2  eggs ');
    });

    test('reports count words separately from units', () {
      final line = parseIngredientLine('1 (15 oz) can black beans, drained');

      expect(line.unit, isNull);
      expect(line.countWord, 'can');
      expect(line.package, ParsedAmount(quantity: Quantity(15), unit: .ounce));
    });

    test('finds headings', () {
      expect(parseIngredientLine('For the sauce:').heading, 'sauce');
      expect(parseIngredientLine('Dressing:').heading, 'Dressing');
      expect(parseIngredientLine('2 cups:').isHeading, isFalse);
    });

    test('parses a line without an amount', () {
      final line = parseIngredientLine('Salt to taste');

      expect(line.quantity, isNull);
      expect(line.name, 'Salt');
      expect(line.preparation, 'to taste');
    });

    test('parses an empty line', () {
      expect(parseIngredientLine(''), const ParsedLine(text: ''));
    });

    test('reads a note after the amount in another unit', () {
      final line = parseIngredientLine('1 cup (240 ml, warm) milk');

      expect(
        line.alternate,
        ParsedAmount(quantity: Quantity(240), unit: .milliliter),
      );
      expect(line.name, 'milk');
      expect(line.preparation, 'warm');
    });

    test('reads the rest as a note when the parenthesis is not closed', () {
      final line = parseIngredientLine('1 cup (240 ml, warm milk');

      expect(
        line.alternate,
        ParsedAmount(quantity: Quantity(240), unit: .milliliter),
      );
      expect(line.name, isNull);
      expect(line.preparation, 'warm milk');
    });

    test('reads a container size with a note after the name', () {
      final line = parseIngredientLine('1 can black beans (15 oz, drained)');

      expect(line.package, ParsedAmount(quantity: Quantity(15), unit: .ounce));
      expect(line.name, 'black beans');
      expect(line.preparation, 'drained');
    });

    test('drops commas at the end of the name', () {
      expect(parseIngredientLine('2 eggs,').name, 'eggs');
    });
  });
}
