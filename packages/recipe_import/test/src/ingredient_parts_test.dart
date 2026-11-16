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

    test('sets the count word, and keeps a size in the name', () {
      final garlic = _parts('3 cloves garlic, minced');
      expect(garlic.countWord, 'clove');
      expect(garlic.unit, isNull);
      expect(garlic.name, 'garlic');
      expect(_parts('1 large egg').name, 'large egg');
      expect(_parts('2 Large Eggs').name, 'Large Eggs');
    });

    test('leaves a line with no name unnamed', () {
      expect(_parts('For the sauce:').name, isNull);
    });
  });
}
