import 'package:nutrition/nutrition.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  final usda = UsdaBrandedClient(
    (_) async => fixture('usda_search_oat_milk.json'),
  );
  final off = OpenFoodFactsClient(
    (url, _) async => url.path.startsWith('/api')
        ? fixtureText('off_product_oatly.json')
        : fixtureText('off_search_oat_milk.json'),
  );
  final failingUsda = UsdaBrandedClient((_) async => throw StateError('down'));
  final failingOff = OpenFoodFactsClient(
    (_, _) async => throw StateError('offline'),
  );

  group('OnlineFoods', () {
    test('lists USDA results first, then Open Food Facts', () async {
      final foods = await OnlineFoods(
        usda: usda,
        openFoodFacts: off,
      ).search('oat milk');

      expect(foods.map((f) => f.food.id.value), [
        'usda:2153416',
        'usda:2209871',
        'off:7394376616228',
        'off:7394376123337',
        'off:7394376620157',
      ]);
    });

    test('keeps one source when the other fails', () async {
      expect(
        await OnlineFoods(
          usda: failingUsda,
          openFoodFacts: off,
        ).search('oat milk'),
        hasLength(3),
      );
    });

    test('fails only when every source does', () async {
      await expectLater(
        OnlineFoods(
          usda: failingUsda,
          openFoodFacts: failingOff,
        ).search('oat milk'),
        throwsStateError,
      );
    });

    test('finds nothing with no sources', () async {
      expect(await OnlineFoods().search('oat milk'), isEmpty);
      expect(await OnlineFoods().lookupBarcode('1'), isNull);
    });

    test('looks up a barcode in the first source that knows it', () async {
      final food = await OnlineFoods(
        usda: usda,
        openFoodFacts: off,
      ).lookupBarcode('7394376616228');

      expect(food!.food.id.value, 'off:7394376616228');
    });
  });
}
