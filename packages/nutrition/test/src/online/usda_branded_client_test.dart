import 'package:domain/domain.dart';
import 'package:nutrition/nutrition.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('UsdaBrandedClient', () {
    late List<Map<String, Object?>> requests;
    final client = UsdaBrandedClient((request) async {
      requests.add(request);
      return fixture('usda_search_oat_milk.json');
    });

    setUp(() => requests = []);

    test('searches through the proxy and reads branded foods', () async {
      final foods = await client.search('oat milk');

      expect(requests.single, {
        'action': 'search',
        'query': 'oat milk',
        'pageSize': 20,
      });
      expect(foods, hasLength(2));
      final (:food, :nutrients, :portions) = foods.first;
      expect(food.id, const FoodId('usda:2153416'));
      expect(food.source, NutritionSource.usda);
      expect(food.name, 'OAT MILK');
      expect(food.brand, 'EXAMPLE');
      expect(nutrients.map((n) => n.nutrientCode), [
        '208',
        '203',
        '205',
        '204',
        '307',
      ]);
      expect(nutrients.first.amountPer100g, 50);
      // "1 cup" on the label, 240 g.
      expect(portions.single.unit, Unit.cup);
      expect(portions.single.amount, Quantity.one);
      expect(portions.single.gramWeight, 240);
    });

    test('keeps no serving measured in milliliters', () async {
      final foods = await client.search('oat milk');

      expect(foods[1].portions, isEmpty);
      expect(foods[1].food.brand, 'Another Co.');
    });

    test('looks up a barcode, ignoring leading zeros', () async {
      final food = await client.lookupBarcode('051500255520');

      expect(requests.single['query'], '051500255520');
      expect(food!.food.externalId, '2153416');
      expect(await client.lookupBarcode('999'), isNull);
      expect(await client.lookupBarcode('--'), isNull);
    });

    test('reads nothing from a malformed response', () {
      expect(parseUsdaSearch(null), isEmpty);
      expect(parseUsdaSearch({'foods': 'x'}), isEmpty);
    });

    test('counts a label serving with no household unit', () {
      final foods = parseUsdaSearch({
        'foods': [
          {
            'fdcId': 1,
            'description': 'BAR',
            'brandName': '',
            'servingSize': 40,
            'servingSizeUnit': 'GRM',
            'householdServingFullText': '1 bar',
          },
        ],
      });

      expect(foods.single.food.brand, isNull);
      expect(foods.single.portions.single.unit, isNull);
      expect(foods.single.portions.single.description, '1 bar');
    });
  });
}
