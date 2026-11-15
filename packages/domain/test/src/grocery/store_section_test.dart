import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('StoreSection.of', () {
    test('finds the section by keyword, ignoring plurals and case', () {
      expect(StoreSection.of('Yellow Onions'), StoreSection.produce);
      expect(
        StoreSection.of('boneless chicken thighs'),
        StoreSection.meatAndSeafood,
      );
      expect(StoreSection.of('large eggs'), StoreSection.dairyAndEggs);
      expect(StoreSection.of('flour tortillas'), StoreSection.bakery);
      expect(StoreSection.of('frozen peas'), StoreSection.frozen);
      expect(StoreSection.of('ground cumin'), StoreSection.spices);
      expect(StoreSection.of('all-purpose flour'), StoreSection.pantry);
      expect(StoreSection.of('dry white wine'), StoreSection.beverages);
    });

    test('prefers the longest matching phrase', () {
      expect(StoreSection.of('sour cream'), StoreSection.dairyAndEggs);
      expect(StoreSection.of('coconut milk'), StoreSection.pantry);
      expect(StoreSection.of('garlic powder'), StoreSection.spices);
      expect(StoreSection.of('garlic cloves'), StoreSection.produce);
      expect(StoreSection.of('chicken broth'), StoreSection.pantry);
      expect(StoreSection.of('peanut butter'), StoreSection.pantry);
      expect(StoreSection.of('red bell pepper'), StoreSection.produce);
      expect(StoreSection.of('black pepper'), StoreSection.spices);
    });

    test('matches whole words only', () {
      expect(StoreSection.of('cornstarch'), StoreSection.pantry);
      expect(StoreSection.of('hamburger buns'), StoreSection.bakery);
    });

    test('is other when nothing matches', () {
      expect(StoreSection.of('paper towels'), StoreSection.other);
      expect(StoreSection.of(''), StoreSection.other);
    });

    test('every keyword lands in its own section', () {
      for (final section in StoreSection.values) {
        for (final keyword in section.keywords) {
          expect(StoreSection.of(keyword), section, reason: keyword);
        }
      }
    });
  });

  group('StoreSection.byName', () {
    test('reads a stored section name', () {
      expect(StoreSection.byName('produce'), StoreSection.produce);
      expect(StoreSection.byName('Snacks'), isNull);
      expect(StoreSection.byName(null), isNull);
    });
  });
}
