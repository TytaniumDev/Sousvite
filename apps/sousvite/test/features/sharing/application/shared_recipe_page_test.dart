import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/sharing/application/shared_recipe_page.dart';

import '../../../helpers/fakes/recipe_fixtures.dart';

void main() {
  group('sharedRecipePage', () {
    test('groups lines and steps by section, loose ones first', () {
      final page = sharedRecipePage(
        RecipeSnapshot(
          recipe: RecipeFixtures.recipe().copyWith(
            sourceName: 'Example',
            sourceUrl: 'https://example.com',
          ),
          ingredientSections: [
            RecipeFixtures.ingredientSection('is1', name: 'Batter'),
            RecipeFixtures.ingredientSection('is2', name: 'Empty'),
          ],
          ingredientLines: [
            RecipeFixtures.line('l1', rawText: '1 cup oats', sectionId: 'is1'),
            RecipeFixtures.line('l2', rawText: 'Salt'),
            RecipeFixtures.line('l3', rawText: 'Gone', sectionId: 'missing'),
          ],
          stepSections: [RecipeFixtures.stepSection('ss1', name: '')],
          steps: [RecipeFixtures.step('s1', text: 'Mix.', sectionId: 'ss1')],
        ),
        yieldText: '1 serving',
      );

      expect(page.toJson(), {
        'title': 'Oat pancakes',
        'yield': '1 serving',
        'sourceName': 'Example',
        'sourceUrl': 'https://example.com',
        'ingredients': [
          {
            'title': null,
            'items': ['Salt', 'Gone'],
          },
          {
            'title': 'Batter',
            'items': ['1 cup oats'],
          },
        ],
        'steps': [
          {
            'title': null,
            'items': ['Mix.'],
          },
        ],
      });
    });
  });
}
