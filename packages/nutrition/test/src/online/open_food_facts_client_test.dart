import 'package:domain/domain.dart';
import 'package:nutrition/nutrition.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('OpenFoodFactsClient', () {
    late List<(Uri, Map<String, String>)> requests;
    late String body;

    OpenFoodFactsClient client({String? userAgent}) => OpenFoodFactsClient(
      (url, headers) async {
        requests.add((url, headers));
        return body;
      },
      userAgent: userAgent,
      pageSize: 3,
    );

    setUp(() => requests = []);

    test('searches with our user agent and reads products', () async {
      body = fixtureText('off_search_granola.json');

      final foods = await OpenFoodFactsClient((url, headers) async {
        requests.add((url, headers));
        return body;
      }, pageSize: 3).search('granola');

      final (url, headers) = requests.single;
      expect(url.host, 'world.openfoodfacts.org');
      expect(url.path, '/cgi/search.pl');
      expect(url.queryParameters['search_terms'], 'granola');
      expect(url.queryParameters['page_size'], '3');
      expect(headers['User-Agent'], OpenFoodFactsClient.defaultUserAgent);

      expect(foods, hasLength(3));
      final (:food, :nutrients, :portions) = foods.first;
      expect(food.id, const FoodId('off:7622210601988'));
      expect(food.source, NutritionSource.openFoodFacts);
      expect(food.name, "Granola L'Original");
      expect(food.brand, 'LU');
      final byCode = {for (final n in nutrients) n.nutrientCode: n};
      expect(byCode['208']!.amountPer100g, 488);
      // Open Food Facts gives sodium in grams; USDA's number is milligrams.
      expect(byCode['307']!.amountPer100g, closeTo(480, 1e-9));
      expect(portions.single.gramWeight, 12.5);
      expect(portions.single.unit, isNull);
    });

    test('leaves out servings in milliliters', () async {
      body = fixtureText('off_search_oat_milk.json');

      final foods = await client().search('oat milk');

      expect(foods, hasLength(3));
      expect(foods.first.portions, isEmpty);
      final vitaminD = foods.first.nutrients.firstWhere(
        (n) => n.nutrientCode == '328',
      );
      // 1.1e-6 g is 1.1 µg.
      expect(vitaminD.amountPer100g, closeTo(1.1, 1e-9));
      expect(requests.single.$2, isEmpty);
    });

    test('looks up a barcode', () async {
      body = fixtureText('off_product_oatly.json');

      final food = await client().lookupBarcode('7394376616228');

      expect(requests.single.$1.path, '/api/v2/product/7394376616228');
      expect(food!.food.externalId, '7394376616228');
    });

    test('is null for an unknown barcode', () async {
      body = '{"code":"00000000","status":0}';
      expect(await client().lookupBarcode('0'), isNull);
    });

    test('skips products without a name, a code, or calories', () {
      expect(
        parseOffSearch({
          'products': [
            {
              'code': '1',
              'product_name': '',
              'nutriments': <String, Object?>{},
            },
            {
              'code': '',
              'product_name': 'x',
              'nutriments': {'energy-kcal_100g': 1},
            },
            {
              'code': '2',
              'product_name': 'No calories',
              'nutriments': {'fat_100g': 1},
            },
            'not a product',
          ],
        }),
        isEmpty,
      );
      expect(parseOffSearch('nope'), isEmpty);
    });
  });
}
