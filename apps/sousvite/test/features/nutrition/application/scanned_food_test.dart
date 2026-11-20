import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/nutrition/application/scanned_food.dart';

import '../fakes.dart';

typedef _F = NutritionFixtures;

void main() {
  group('scannedLineText', () {
    test('starts with one label serving in grams', () {
      expect(
        scannedLineText(_F.packaged('Creamy Peanut Butter', servingGrams: 32)),
        '32 g Creamy Peanut Butter',
      );
      expect(
        scannedLineText(_F.packaged('Granola', servingGrams: 12.5)),
        '12.5 g Granola',
      );
    });

    test('is the name alone without a serving', () {
      expect(scannedLineText(_F.packaged(' Oat Milk ')), 'Oat Milk');
      expect(
        scannedLineText(_F.packaged('Oat Milk', servingGrams: 0)),
        'Oat Milk',
      );
    });
  });
}
