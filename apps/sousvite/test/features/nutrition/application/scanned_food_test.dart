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

  group('labelServingGrams', () {
    test('is the label serving in grams', () {
      expect(labelServingGrams(_F.packaged('Granola', servingGrams: 40)), 40);
    });

    test('is null without a serving that weighs something', () {
      expect(labelServingGrams(_F.packaged('Oat Milk')), isNull);
      expect(
        labelServingGrams(_F.packaged('Oat Milk', servingGrams: 0)),
        isNull,
      );
    });
  });

  test('formatGrams keeps one decimal at most', () {
    expect(formatGrams(32), '32');
    expect(formatGrams(12.5), '12.5');
    expect(formatGrams(12.54), '12.5');
  });
}
