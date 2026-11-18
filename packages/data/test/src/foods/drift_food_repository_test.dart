import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:sync/sync.dart';
import 'package:test/test.dart';

import '../../helpers/bundled_foods_fixture.dart';
import '../../helpers/test_device.dart';

/// A test device with the food repository over the bundled fixture.
final class _Device(super.id, super.space) extends TestDevice {
  late final bundled = BundledFoods(bundledFoodsFixture());

  late final foods = DriftFoodRepository(
    database,
    recorder: recorder,
    bundled: bundled,
  );

  @override
  Map<String, EntityApplier> get appliers => foods.appliers;

  /// Adds an ingredient line to [recipeId], as the recipe repository would.
  Future<void> addLine(String lineId, String recipeId) => database
      .into(database.ingredientLines)
      .insert(
        IngredientLinesCompanion.insert(
          id: lineId,
          recipeId: recipeId,
          rawText: 'butter',
          sortKey: 'a',
        ),
      );
}

const _brandedId = FoodId('off:123');
const _branded = Food(
  id: _brandedId,
  source: NutritionSource.openFoodFacts,
  externalId: '123',
  name: 'Butter, salted',
  brand: 'Acme',
);
const _brandedNutrients = [
  FoodNutrient(foodId: _brandedId, nutrientCode: '208', amountPer100g: 720),
];
final _brandedPortions = [
  FoodPortion(
    id: const FoodPortionId('off:123:tbsp'),
    foodId: _brandedId,
    amount: Quantity(1),
    gramWeight: 14,
    unit: Unit.tablespoon,
  ),
];

NutritionMatch _match(String id, String lineId, {FoodId? foodId}) =>
    NutritionMatch(
      id: NutritionMatchId(id),
      ingredientLineId: IngredientLineId(lineId),
      foodId: foodId ?? const FoodId('usda:1'),
      source: NutritionSource.usda,
      gramWeight: 14.2,
    );

void main() {
  late InMemorySyncSpace space;
  late List<_Device> devices;

  _Device device(String id) {
    final created = _Device(id, space);
    devices.add(created);
    return created;
  }

  setUp(() {
    space = InMemorySyncSpace();
    devices = [];
  });

  tearDown(() async {
    for (final device in devices) {
      device.bundled.close();
      await device.database.close();
    }
  });

  group('foods', () {
    test('reads bundled foods', () async {
      final foods = device('phone').foods;
      const id = FoodId('usda:1');

      expect((await foods.getFood(id))?.name, 'Butter, without salt');
      expect(await foods.getNutrients(id), hasLength(2));
      expect(await foods.getPortions(id), hasLength(2));
      expect(await foods.getFood(const FoodId('missing')), isNull);
      expect(await foods.genericFoods(), hasLength(3));
    });

    test('reads nothing bundled without the bundled file', () async {
      final phone = device('phone');
      final foods = DriftFoodRepository(
        phone.database,
        recorder: phone.recorder,
      );
      const id = FoodId('usda:1');

      expect(await foods.getFood(id), isNull);
      expect(await foods.getNutrients(id), isEmpty);
      expect(await foods.getPortions(id), isEmpty);
      expect(await foods.searchFoods('butter'), isEmpty);
      expect(await foods.genericFoods(), isEmpty);
    });

    test('caches a food and syncs it to another device', () async {
      final phone = device('phone');
      final laptop = device('laptop');
      await phone.foods.saveFood(
        _branded,
        nutrients: _brandedNutrients,
        portions: _brandedPortions,
      );
      await phone.engine.sync();
      await laptop.engine.sync();

      for (final foods in [phone.foods, laptop.foods]) {
        expect(await foods.getFood(_brandedId), _branded);
        expect(await foods.getNutrients(_brandedId), _brandedNutrients);
        expect(await foods.getPortions(_brandedId), _brandedPortions);
      }
    });

    test('a refetch replaces the nutrients and records only them', () async {
      final phone = device('phone');
      await phone.foods.saveFood(
        _branded,
        nutrients: _brandedNutrients,
        portions: _brandedPortions,
      );
      const refetched = [
        FoodNutrient(foodId: _brandedId, nutrientCode: '203', amountPer100g: 1),
      ];
      await phone.foods.saveFood(
        _branded,
        nutrients: refetched,
        portions: _brandedPortions,
      );

      expect(await phone.foods.getNutrients(_brandedId), refetched);
      final fields = [for (final change in await phone.changes()) change.field];
      expect(fields.where((field) => field == 'nutrients'), hasLength(2));
      expect(fields.where((field) => field == 'name'), hasLength(1));
    });

    test('a cached food with no portions has none', () async {
      final phone = device('phone');
      await phone.foods.saveFood(_branded, nutrients: const [], portions: []);
      expect(await phone.foods.getPortions(_brandedId), isEmpty);
    });

    test('searches cached and bundled foods, best first', () async {
      final foods = device('phone').foods;
      await foods.saveFood(
        _branded,
        nutrients: _brandedNutrients,
        portions: _brandedPortions,
      );

      expect(
        [for (final food in await foods.searchFoods('Butter')) food.id],
        [
          const FoodId('usda:2'),
          _brandedId,
          const FoodId('usda:1'),
          const FoodId('usda:3'),
        ],
      );
      expect(await foods.searchFoods('butter', limit: 1), hasLength(1));
      expect(await foods.searchFoods('  '), isEmpty);
    });

    test('a cached copy of a bundled food is listed once', () async {
      final foods = device('phone').foods;
      const id = FoodId('usda:2');
      final bundled = (await foods.getFood(id))!;
      await foods.saveFood(bundled, nutrients: const [], portions: const []);

      expect(
        [for (final food in await foods.searchFoods('salted')) food.id],
        [id],
      );
    });

    test('waits for the required fields', () {
      final codec = CachedFoodCodec();
      expect(codec.decode('x', {'source': 'usda'}), isNull);
      expect(codec.decode('x', {'name': 'Butter'}), isNull);
    });
  });

  group('matches', () {
    test('lists the matches of a recipe and syncs them', () async {
      final phone = device('phone');
      final laptop = device('laptop');
      for (final device in [phone, laptop]) {
        await device.addLine('l1', 'r1');
        await device.addLine('l2', 'r2');
      }
      await phone.foods.saveMatch(_match('m1', 'l1'));
      await phone.foods.saveMatch(_match('m2', 'l2'));
      await phone.engine.sync();
      await laptop.engine.sync();

      expect(await laptop.foods.watchMatches(const RecipeId('r1')).first, [
        _match('m1', 'l1'),
      ]);
    });

    test('a new match for a line replaces the old one', () async {
      final phone = device('phone');
      final laptop = device('laptop');
      for (final device in [phone, laptop]) {
        await device.addLine('l1', 'r1');
      }
      await phone.foods.saveMatch(_match('m1', 'l1'));
      await phone.engine.sync();
      await laptop.engine.sync();

      final picked = _match(
        'm2',
        'l1',
        foodId: const FoodId('usda:2'),
      ).copyWith(userConfirmed: true);
      await phone.foods.saveMatch(picked);
      await phone.engine.sync();
      await laptop.engine.sync();

      for (final device in [phone, laptop]) {
        expect(await device.foods.watchMatches(const RecipeId('r1')).first, [
          picked,
        ]);
      }
      expect(await phone.tombstones(), {'m1'});
    });

    test('two devices matching one line keep one match', () async {
      final phone = device('phone');
      final laptop = device('laptop');
      for (final device in [phone, laptop]) {
        await device.addLine('l1', 'r1');
      }
      await phone.foods.saveMatch(_match('m1', 'l1'));
      await laptop.foods.saveMatch(_match('m2', 'l1'));
      await phone.engine.sync();
      await laptop.engine.sync();
      await phone.engine.sync();

      expect(
        await phone.foods.watchMatches(const RecipeId('r1')).first,
        hasLength(1),
      );
    });

    test('deletes a match on every device', () async {
      final phone = device('phone');
      final laptop = device('laptop');
      for (final device in [phone, laptop]) {
        await device.addLine('l1', 'r1');
      }
      await phone.foods.saveMatch(_match('m1', 'l1'));
      await phone.engine.sync();
      await laptop.engine.sync();

      await phone.foods.deleteMatch(const NutritionMatchId('m1'));
      await phone.engine.sync();
      await laptop.engine.sync();

      expect(
        await laptop.foods.watchMatches(const RecipeId('r1')).first,
        isEmpty,
      );
    });

    test('waits for the required fields', () {
      expect(NutritionMatchCodec().decode('m1', {'source': 'usda'}), isNull);
    });
  });
}
