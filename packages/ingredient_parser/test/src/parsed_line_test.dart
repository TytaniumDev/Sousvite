import 'package:domain/domain.dart';
import 'package:ingredient_parser/ingredient_parser.dart';
import 'package:test/test.dart';

void main() {
  final ounces = ParsedAmount(quantity: Quantity(15), unit: Unit.ounce);

  group('ParsedAmount', () {
    test('compares by value', () {
      expect(ounces, ParsedAmount(quantity: Quantity(15), unit: Unit.ounce));
      expect(
        ounces.hashCode,
        ParsedAmount(quantity: Quantity(15), unit: Unit.ounce).hashCode,
      );
      expect(ounces, isNot(ParsedAmount(quantity: Quantity(14), unit: .ounce)));
    });

    test('has a debug form', () {
      expect(ounces.toString(), '15 ounce');
      expect(
        ParsedAmount(
          quantity: Quantity(13),
          quantityMax: Quantity(14),
          unit: .ounce,
        ).toString(),
        '13-14 ounce',
      );
    });
  });

  group('ParsedLine', () {
    final line = ParsedLine(
      text: '1 (15 oz) can beans, drained',
      quantity: Quantity.one,
      quantityMax: Quantity(2),
      countWord: 'can',
      package: ounces,
      alternate: ounces,
      size: 'large',
      name: 'beans',
      preparation: 'drained',
    );

    test('compares by value', () {
      expect(line, parseIngredientLine(line.text).copyForTest(line));
      expect(line.hashCode, line.copyForTest(line).hashCode);
      expect(line, isNot(const ParsedLine(text: 'beans')));
    });

    test('knows when it is a heading', () {
      expect(
        const ParsedLine(text: 'Sauce:', heading: 'Sauce').isHeading,
        isTrue,
      );
      expect(line.isHeading, isFalse);
    });

    test('has a debug form', () {
      expect(
        line.toString(),
        'quantity: 1, quantityMax: 2, countWord: can, package: 15 ounce, '
        'alternate: 15 ounce, size: large, name: beans, preparation: drained',
      );
      expect(
        const ParsedLine(text: 'x', heading: 'Sauce', unit: .cup).toString(),
        'heading: Sauce, unit: cup',
      );
    });
  });
}

extension on ParsedLine {
  /// A new line with the same parts as [other], so equality is not
  /// identity.
  ParsedLine copyForTest(ParsedLine other) => ParsedLine(
    text: other.text,
    heading: other.heading,
    quantity: other.quantity,
    quantityMax: other.quantityMax,
    unit: other.unit,
    countWord: other.countWord,
    package: other.package,
    alternate: other.alternate,
    size: other.size,
    name: other.name,
    preparation: other.preparation,
  );
}
