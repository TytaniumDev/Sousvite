// Measures how often the matcher picks the right USDA food for common
// recipe ingredients (PRD §8 asks for 90%).
//
// test/fixtures/matching/usda_foods.tsv lists every food in the bundled
// file. After regenerating that file with tools/usda_builder, refresh it
// from the repository root with:
//
//   sqlite3 -separator "$(printf '\t')" \
//     apps/sousvite/assets/nutrition/usda_foods.sqlite \
//     'SELECT id, name FROM foods ORDER BY id' \
//     > packages/nutrition/test/fixtures/matching/usda_foods.tsv

import 'dart:io';

import 'package:domain/domain.dart';
import 'package:nutrition/src/matching/food_match.dart';
import 'package:nutrition/src/matching/food_matcher.dart';
import 'package:test/test.dart';

/// The share of fixture ingredients that must match correctly.
const _target = 0.9;

void main() {
  test('matches at least 90% of common ingredients correctly', () {
    final foods = [
      for (final [id, name] in _rows('usda_foods.tsv'))
        Food(
          id: FoodId(id),
          source: NutritionSource.usda,
          externalId: id.substring('usda:'.length),
          name: name,
        ),
    ];
    final matcher = FoodMatcher(foods);

    final failures = <String>[];
    final cases = _rows('common_ingredients.tsv');
    for (final [ingredient, expected] in cases) {
      final accepted = expected.split(' | ');
      final actual = switch (matcher.match(ingredient)) {
        FoodMatched(:final food) => food.name,
        FoodUnmatched() => '-',
      };
      if (!accepted.contains(actual)) {
        failures.add('$ingredient: got "$actual", expected "$expected"');
      }
    }

    final accuracy = 1 - failures.length / cases.length;
    printOnFailure(failures.join('\n'));
    // Reported in the CI log, so changes in accuracy are visible.
    // ignore: avoid_print, the accuracy is meant for the CI log.
    print(
      'Food matching accuracy: ${(accuracy * 100).toStringAsFixed(1)}% '
      '(${cases.length - failures.length} of ${cases.length})',
    );
    expect(
      accuracy,
      greaterThanOrEqualTo(_target),
      reason: failures.join('\n'),
    );
  });
}

List<List<String>> _rows(String name) => [
  for (final line in File('test/fixtures/matching/$name').readAsLinesSync())
    if (line.isNotEmpty && !line.startsWith('#')) line.split('\t'),
];
