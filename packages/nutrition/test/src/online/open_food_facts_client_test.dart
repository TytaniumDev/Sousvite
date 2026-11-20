import 'dart:convert';

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

      final product = await client().lookupBarcode('7394376616228');

      expect(requests.single.$1.path, '/api/v2/product/7394376616228');
      expect(
        requests.single.$1.queryParameters['fields'],
        endsWith(',image_front_url'),
      );
      expect(product!.food.food.externalId, '7394376616228');
      expect(
        product.imageUrl,
        Uri.parse(
          'https://images.openfoodfacts.org/images/products/739/437/661/6228/'
          'front_en.197.400.jpg',
        ),
      );
    });

    test('looks up a barcode without a usable photo', () async {
      for (final photo in ['null', '"not a url"', '"ftp://x/y.jpg"', '3']) {
        body = jsonEncode({
          'status': 1,
          'product': {
            'code': '1',
            'product_name': 'Peanut butter',
            'nutriments': {'energy-kcal_100g': 600},
            'image_front_url': jsonDecode(photo),
          },
        });

        final product = await client().lookupBarcode('1');

        expect(product!.food.food.name, 'Peanut butter', reason: photo);
        expect(product.imageUrl, isNull, reason: photo);
      }
    });

    test('is null for a barcode product it cannot use', () async {
      body = '{"status":1,"product":{"code":"1","product_name":"Water"}}';
      expect(await client().lookupBarcode('1'), isNull);
    });

    test('reads a household volume from the label serving', () {
      Map<String, Object?> product(String servingSize) => {
        'code': '1',
        'product_name': 'Peanut butter',
        'nutriments': {'energy-kcal_100g': 600},
        'serving_quantity': 32,
        'serving_quantity_unit': 'g',
        'serving_size': servingSize,
      };
      List<FoodPortion> portions(String servingSize) => parseOffSearch({
        'products': [product(servingSize)],
      }).single.portions;

      final spoons = portions('2 tbsp (32 g)').single;
      expect(spoons.amount, Quantity(2));
      expect(spoons.unit, Unit.tablespoon);
      expect(spoons.gramWeight, 32);
      expect(spoons.description, '2 tbsp (32 g)');

      // A serving that is a count or a weight stays one serving, so
      // counted lines ("1 bar") can still be weighed with it.
      for (final text in ['1 serving (32 g)', '32 g', '1 bar']) {
        final serving = portions(text).single;
        expect(serving.amount, Quantity.one, reason: text);
        expect(serving.unit, isNull, reason: text);
      }
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
