/// The word lists and weights that tune food matching. Keeping them in one
/// file makes the matcher's behavior easy to review and adjust against the
/// accuracy fixture in `test/fixtures/matching/`.
library;

import 'package:nutrition/src/matching/synonym_table.dart';

/// Points lost for each word in a food's name that the ingredient doesn't
/// mention, so "Garlic, raw" beats "Garlic, pickled, sliced".
const extraWordPenalty = 3.0;

/// Points gained when the food's leading name segment is entirely in the
/// ingredient, so "garlic" picks "Garlic, raw" over "Spices, garlic powder".
const identityMatchBonus = 15.0;

/// Points lost by branded and Open Food Facts foods, so generic USDA foods
/// win unless the ingredient names the product.
const nonGenericPenalty = 20.0;

/// USDA category words that can lead a name before the food itself.
const categoryWords = {
  'agent',
  'beverage',
  'leavening',
  'nut',
  'seed',
  'spice',
};

/// Words in food names that say nothing the cook would have to mention.
const neutralWords = {
  'all',
  'fresh',
  'mature',
  'plain',
  'raw',
  'regular',
};

/// Words that make a food an unlikely match unless the ingredient says
/// them, with the points they cost instead of [extraWordPenalty].
const unwantedWords = {
  'babyfood': 40.0,
  'commodity': 20.0,
  'distribution': 20.0,
  'fast': 20.0,
  'formula': 40.0,
  'imitation': 20.0,
  'infant': 40.0,
  'restaurant': 20.0,
  'school': 20.0,
  'substitute': 20.0,
  'canned': 6.0,
  'cooked': 6.0,
  'boiled': 6.0,
  'dehydrated': 8.0,
  'dried': 6.0,
  'frozen': 6.0,
  'prepared': 6.0,
};

/// Cooks' words rewritten to USDA's, and preparation words removed.
final standardSynonyms = SynonymTable({
  // Preparation and size words that don't change the food.
  for (final word in _ignoredWords) word: '',
  ..._phrases,
});

const _ignoredWords = [
  'beaten',
  'boneless',
  'chopped',
  'coarsely',
  'cold',
  'cubed',
  'diced',
  'divided',
  'extra virgin',
  'finely',
  'freshly',
  'grated',
  'halved',
  'large',
  'medium',
  'melted',
  'minced',
  'optional',
  'organic',
  'packed',
  'peeled',
  'room temperature',
  'roughly',
  'shredded',
  'sifted',
  'sliced',
  'small',
  'softened',
  'thinly',
  'to taste',
  'trimmed',
];

const _phrases = {
  'all purpose flour': 'wheat flour white all purpose',
  'flour': 'wheat flour white all purpose',
  'garlic clove': 'garlic',
  'kosher salt': 'salt table',
  'sea salt': 'salt table',
  'salt': 'salt table',
  'scallion': 'green onion',
  'unsalted': 'without salt',
};
