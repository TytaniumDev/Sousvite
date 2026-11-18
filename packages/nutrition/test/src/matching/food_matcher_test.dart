import 'package:domain/domain.dart';
import 'package:nutrition/src/matching/food_match.dart';
import 'package:nutrition/src/matching/food_matcher.dart';
import 'package:nutrition/src/matching/synonym_table.dart';
import 'package:test/test.dart';

Food _usda(String id, String name) => Food(
  id: FoodId('usda:$id'),
  source: NutritionSource.usda,
  externalId: id,
  name: name,
);

Matcher _clear(Matcher isClear) =>
    isA<FoodMatched>().having((m) => m.isClear, 'isClear', isClear);

void main() {
  final garlic = _usda('1', 'Garlic, raw');
  final garlicPowder = _usda('2', 'Spices, garlic powder');
  final pickledGarlic = _usda('3', 'Garlic, pickled, sliced');
  final babyGarlic = _usda('4', 'Babyfood, garlic');
  final butter = _usda('5', 'Butter, salted');
  final unsalted = _usda('6', 'Butter, without salt');
  final milk = _usda('7', 'Milk, whole, 3.25% milkfat, with added vitamin D');
  final buttermilk = _usda('8', 'Milk, buttermilk, fluid, whole');

  final matcher = FoodMatcher([
    garlic,
    garlicPowder,
    pickledGarlic,
    babyGarlic,
    butter,
    unsalted,
    milk,
    buttermilk,
  ]);

  group(FoodMatcher, () {
    group('match', () {
      test('picks the plain food over processed ones', () {
        expect(
          matcher.match('garlic'),
          isA<FoodMatched>().having((m) => m.food, 'food', garlic),
        );
      });

      test('applies the standard synonyms', () {
        expect(
          matcher.match('2 Tbsp unsalted butter, softened'),
          isA<FoodMatched>().having((m) => m.food, 'food', unsalted),
        );
        expect(
          matcher.match('garlic cloves'),
          isA<FoodMatched>().having((m) => m.food, 'food', garlic),
        );
      });

      test('weighs late name segments less', () {
        expect(
          matcher.match('whole milk'),
          isA<FoodMatched>().having((m) => m.food, 'food', milk),
        );
      });

      test('is unmatched when no food has the main word', () {
        expect(matcher.match('soy sauce'), isA<FoodUnmatched>());
      });

      test('is unmatched when a food covers too little of the name', () {
        expect(
          matcher.match('roasted black garlic paste'),
          isA<FoodUnmatched>(),
        );
      });

      test('is unmatched for a name with no words', () {
        expect(matcher.match('chopped, to taste'), isA<FoodUnmatched>());
      });

      group('isClear', () {
        final leaves = FoodMatcher([
          _usda('9', 'Taro leaves, raw'),
          _usda('10', 'Soy sauce made from soy and wheat (shoyu)'),
        ]);

        test('when the food is named in full', () {
          expect(matcher.match('garlic'), _clear(isTrue));
        });

        test('when the food fits well without being named in full', () {
          expect(leaves.match('soy sauce'), _clear(isTrue));
        });

        test('not when the food only shares the main word', () {
          expect(leaves.match('mint leaves'), _clear(isFalse));
        });
      });

      test('reports the score of the best food', () {
        final match = matcher.match('garlic') as FoodMatched;

        expect(match.score, matcher.rank('garlic').first.score);
      });
    });

    group('rank', () {
      test('orders candidates best first, unwanted foods last', () {
        final foods = matcher.rank('garlic').map((r) => r.food).toList();

        expect(foods.first, garlic);
        expect(foods.last, babyGarlic);
        expect(foods, hasLength(4));
      });

      test('keeps at most the limit', () {
        expect(matcher.rank('garlic', limit: 2), hasLength(2));
      });

      test('prefers generic USDA foods over branded and Open Food Facts', () {
        const branded = Food(
          id: FoodId('usda:9'),
          source: NutritionSource.usda,
          externalId: '9',
          name: 'Butter, salted',
          brand: 'Acme',
        );
        const openFoodFacts = Food(
          id: FoodId('off:1'),
          source: NutritionSource.openFoodFacts,
          externalId: '1',
          name: 'Butter, salted',
        );
        final ranked = FoodMatcher([branded, openFoodFacts, butter])
            .rank('butter');

        expect(ranked.first.food, butter);
      });

      test('breaks ties by shorter name, then id, whatever the order', () {
        final a = _usda('b', 'Beans, lima');
        final b = _usda('a', 'Beans, navy');
        final c = _usda('c', 'Beans, pinto');
        final forward = FoodMatcher([a, b, c]).rank('beans');
        final backward = FoodMatcher([c, b, a]).rank('beans');

        expect(forward.map((r) => r.food), [b, a, c]);
        expect(backward.map((r) => r.food), [b, a, c]);
      });

      test('uses the synonyms it is given', () {
        final custom = FoodMatcher([
          butter,
          unsalted,
        ], synonyms: SynonymTable(phrases: {'sweet cream': 'without salt'}));

        expect(custom.rank('sweet cream butter').first.food, unsalted);
        expect(custom.rank('unsalted butter').first.food, butter);
      });
    });
  });
}
