import 'package:domain/domain.dart';
import 'package:ingredient_parser/src/units.dart';
import 'package:test/test.dart';

void main() {
  group('unitAt', () {
    test('finds a measuring unit and the text after it', () {
      expect(unitAt('cups flour'), (
        unit: Unit.cup,
        countWord: null,
        rest: 'flour',
      ));
      expect(unitAt('Tbsp. butter')?.unit, Unit.tablespoon);
      expect(unitAt('fl. oz. cream')?.unit, Unit.fluidOunce);
    });

    test('tells T from t', () {
      expect(unitAt('T sugar')?.unit, Unit.tablespoon);
      expect(unitAt('t sugar')?.unit, Unit.teaspoon);
    });

    test('knows misspellings', () {
      expect(unitAt('teaspooon salt')?.unit, Unit.teaspoon);
      expect(unitAt('tea spoons salt')?.unit, Unit.teaspoon);
      expect(unitAt('TB oil')?.unit, Unit.tablespoon);
    });

    test('finds a count word in its singular form', () {
      expect(unitAt('cloves garlic'), (
        unit: null,
        countWord: 'clove',
        rest: 'garlic',
      ));
      expect(unitAt('Tins tomatoes')?.countWord, 'can');
    });

    test('returns null for other words', () {
      expect(unitAt('garlic'), isNull);
      expect(unitAt('(15 oz)'), isNull);
    });
  });

  test('isMeasure', () {
    expect(isMeasure(.cup), isTrue);
    expect(isMeasure(.pinch), isFalse);
    expect(isMeasure(null), isFalse);
  });
}
