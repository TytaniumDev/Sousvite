import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(NutrientPrecision, () {
    test('rounds calories and milligrams to whole numbers', () {
      expect(NutrientPrecision.whole.format(523.6), '524');
      expect(NutrientPrecision.whole.format(4.4), '4');
    });

    test('keeps one decimal for grams below 10', () {
      expect(NutrientPrecision.grams.format(4.46), '4.5');
      expect(NutrientPrecision.grams.format(0.04), '0');
      expect(NutrientPrecision.grams.format(3), '3');
    });

    test('rounds grams at 10 and above to whole numbers', () {
      expect(NutrientPrecision.grams.format(12.5), '13');
      expect(NutrientPrecision.grams.format(10), '10');
    });
  });
}
