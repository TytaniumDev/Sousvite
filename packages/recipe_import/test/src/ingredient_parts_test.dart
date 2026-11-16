import 'package:domain/domain.dart';
import 'package:ingredient_parser/ingredient_parser.dart';
import 'package:recipe_import/src/ingredient_parts.dart';
import 'package:test/test.dart';

IngredientLine _parts(String text) => withParsedParts(
  IngredientLine(
    id: const IngredientLineId('l1'),
    recipeId: const RecipeId('r1'),
    rawText: text,
    sortKey: const SortKey('a'),
  ),
  parseIngredientLine(text),
);

void main() {
  group('withParsedParts', () {
    test('fills in the amount, unit, name, and preparation', () {
      final line = _parts('2-3 cups rolled oats, toasted');

      expect(line.quantity, Quantity(2));
      expect(line.quantityMax, Quantity(3));
      expect(line.unit, Unit.cup);
      expect(line.name, 'rolled oats');
      expect(line.preparation, 'toasted');
      expect(line.rawText, '2-3 cups rolled oats, toasted');
    });

    test('keeps a size and count word in the name as written', () {
      expect(_parts('3 cloves garlic, minced').name, 'cloves garlic');
      expect(_parts('1 large egg').name, 'large egg');
      expect(_parts('2 Garlic Cloves').name, 'Garlic Cloves');
    });

    test('leaves a line with no name unnamed', () {
      expect(_parts('For the sauce:').name, isNull);
    });
  });
}
