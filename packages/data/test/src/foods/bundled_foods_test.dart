import 'dart:io';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../../helpers/bundled_foods_fixture.dart';

void main() {
  late BundledFoods bundled;

  setUp(() => bundled = BundledFoods(bundledFoodsFixture()));
  tearDown(() => bundled.close());

  test('reads a food with its nutrients and portions', () {
    const id = FoodId('usda:1');
    expect(
      bundled.food(id),
      const Food(
        id: id,
        source: NutritionSource.usda,
        externalId: '1',
        name: 'Butter, without salt',
      ),
    );
    expect(bundled.nutrients(id), const [
      FoodNutrient(foodId: id, nutrientCode: '203', amountPer100g: 0.85),
      FoodNutrient(foodId: id, nutrientCode: '208', amountPer100g: 717),
    ]);
    expect(bundled.portions(id), [
      FoodPortion(
        id: const FoodPortionId('usda:1:pat'),
        foodId: id,
        amount: Quantity(1),
        gramWeight: 5,
        description: '1 pat',
      ),
      FoodPortion(
        id: const FoodPortionId('usda:1:tbsp'),
        foodId: id,
        amount: Quantity(1),
        gramWeight: 14.2,
        unit: Unit.tablespoon,
        description: '1 tbsp',
      ),
    ]);
    expect(bundled.food(const FoodId('missing')), isNull);
  });

  test('finds foods whose names hold every word', () {
    expect(
      [
        for (final food in bundled.search(['butter', 'salt'])) food.id,
      ],
      [const FoodId('usda:1'), const FoodId('usda:2')],
    );
    expect(bundled.search([]), isEmpty);
  });

  test('opens the file from its bytes, read-only', () {
    final directory = Directory.systemTemp.createTempSync('bundled');
    addTearDown(() => directory.deleteSync(recursive: true));
    final path = '${directory.path}/usda_foods.sqlite';
    bundledFoodsFixture()
      ..execute('VACUUM INTO ?', [path])
      ..close();

    final opened = BundledFoods.fromBytes(
      sqlite3,
      File(path).readAsBytesSync(),
    );
    addTearDown(opened.close);

    expect(opened.food(const FoodId('usda:2'))?.name, 'Butter, salted');
    expect(
      () => opened.database.execute('DELETE FROM foods'),
      throwsA(isA<SqliteException>()),
    );
  });
}
