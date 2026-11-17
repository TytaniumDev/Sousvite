import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';

Food _food(String name, {String? brand}) => Food(
  id: FoodId(name),
  source: NutritionSource.usda,
  externalId: name,
  name: name,
  brand: brand,
);

void main() {
  test('splits a query into lowercase words', () {
    expect(foodSearchWords(' Butter,  SALTED '), ['butter', 'salted']);
    expect(foodSearchWords(' , '), isEmpty);
  });

  test('escapes LIKE wildcards', () {
    expect(foodSearchPatterns([r'50%_a\b']), [r'%50\%\_a\\b%']);
    expect(
      foodSearchWhere(['a', 'b']),
      r"lower(name) LIKE ? ESCAPE '\' AND lower(name) LIKE ? ESCAPE '\'",
    );
  });

  test('ranks names that start with the first word, then shorter, '
      'then generic, then by name', () {
    final cookies = _food('Cookies, butter');
    final buttermilk = _food('Buttermilk');
    final branded = _food('Butter, salted', brand: 'Acme');
    final salted = _food('Butter, salted');
    final unsalted = _food('Butter, unsalted');
    final plain = _food('Butter, plain!');

    expect(
      rankFoods(
        [cookies, buttermilk, unsalted, branded, plain, salted],
        ['butter'],
      ),
      [plain, salted, branded, unsalted, buttermilk, cookies],
    );
    expect(rankFoods([salted], []), [salted]);
  });
}
