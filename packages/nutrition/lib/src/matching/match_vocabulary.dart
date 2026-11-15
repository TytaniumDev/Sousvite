/// The word lists and weights that tune food matching. Keeping them in one
/// file makes the matcher's behavior easy to review and adjust against the
/// accuracy fixture in `test/fixtures/matching/`.
library;

import 'package:nutrition/src/matching/synonym_table.dart';

/// Points lost for each word in a food's first two name segments that the
/// ingredient doesn't mention, so "Garlic, raw" beats "Garlic, pickled".
const extraWordPenalty = 3.0;

/// How much an extra word counts from the third name segment on. USDA puts
/// the food first and the fine print last ("Milk, whole, 3.25% milkfat,
/// with added vitamin D"), so late words matter less.
const laterSegmentWeight = 0.5;

/// Points gained when the food's leading name segment is entirely in the
/// ingredient, so "garlic" picks "Garlic, raw" over "Spices, garlic powder".
const identityMatchBonus = 15.0;

/// Points lost by branded and Open Food Facts foods, so generic USDA foods
/// win unless the ingredient names the product.
const nonGenericPenalty = 20.0;

/// USDA category words that can lead a name before the food itself.
const categoryWords = {
  'agent',
  'alcoholic',
  'beverage',
  'candy',
  'fish',
  'leavening',
  'nut',
  'seed',
  'spice',
};

/// Whether [token] in a food's name says nothing the cook would have to
/// mention: numbers, single letters ("vitamin D"), [categoryWords], and
/// [neutralWords].
bool isNeutralWord(String token) =>
    token.length == 1 ||
    int.tryParse(token) != null ||
    categoryWords.contains(token) ||
    neutralWords.contains(token);

/// Words in food names that say nothing the cook would have to mention.
/// Several mark USDA's "typical" entry: "all commercial varieties",
/// "year round average", "Includes foods for USDA's Food Distribution
/// Program".
const neutralWords = {
  'added',
  'all',
  'average',
  'commercial',
  'distribution',
  'food',
  'fresh',
  'include',
  'mature',
  'plain',
  'program',
  'raw',
  'regular',
  'round',
  'uncooked',
  'unprepared',
  'usda',
  'variety',
  'vitamin',
  'year',
};

/// Words that make a food an unlikely match unless the ingredient says
/// them, with the points they cost instead of [extraWordPenalty].
const unwantedWords = {
  'babyfood': 40.0,
  'fast': 20.0,
  'formula': 40.0,
  'imitation': 20.0,
  'infant': 40.0,
  'meatless': 30.0,
  'restaurant': 20.0,
  'school': 20.0,
  'substitute': 20.0,
  'boiled': 6.0,
  'canned': 6.0,
  'cooked': 6.0,
  'dehydrated': 8.0,
  'dried': 6.0,
  'free': 6.0,
  'frozen': 6.0,
  'glazed': 6.0,
  'low': 6.0,
  'lowfat': 6.0,
  'mix': 6.0,
  'nonfat': 6.0,
  'prepared': 6.0,
  'reduced': 6.0,
  'skim': 6.0,
};

/// Cooks' words rewritten to USDA's. Each replacement ends with its main
/// word (see [SynonymTable]).
final standardSynonyms = SynonymTable(
  phrases: {for (final word in _ignoredWords) word: '', ..._phrases},
  defaults: _defaults,
);

/// Preparation, size, and quality words that don't change the food.
const _ignoredWords = [
  'beaten',
  'chopped',
  'coarsely',
  'cold',
  'cubed',
  'diced',
  'divided',
  'finely',
  'freshly',
  'good quality',
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

/// Phrases rewritten wherever they appear.
const _phrases = {
  'all purpose flour': 'wheat white all purpose flour',
  'beef broth': 'ready serve beef broth',
  'black olive': 'ripe olive',
  'beef stock': 'ready serve beef broth',
  'celery rib': 'celery',
  'celery stalk': 'celery',
  'cherry tomato': 'grape tomato',
  'chicken broth': 'ready serve chicken broth',
  'chicken stock': 'ready serve chicken broth',
  'chocolate chip': 'semisweet chocolate',
  'confectioners sugar': 'powdered sugar',
  'crushed red pepper': 'red cayenne pepper',
  'fresh ginger': 'ginger root',
  'garlic clove': 'garlic',
  'green onion': 'scallion',
  'half and half': 'half and half cream',
  'heavy cream': 'heavy whipping cream',
  'icing sugar': 'powdered sugar',
  'ketchup': 'catsup',
  'kosher salt': 'table salt',
  'lemon zest': 'lemon peel',
  'lime zest': 'lime peel',
  'orange zest': 'orange peel',
  'panko': 'plain dry bread crumb',
  'red pepper flake': 'red cayenne pepper',
  'sea salt': 'table salt',
  'semisweet chocolate chip': 'semisweet chocolate',
  'sour cream': 'cultured sour cream',
  'soy sauce': 'shoyu soy sauce',
  'spring onion': 'scallion',
  'tomato sauce': 'canned tomato product sauce',
  'unsalted': 'without salt',
  'yeast': 'active dry yeast',
};

/// Whole names rewritten to the form a recipe usually means.
const _defaults = {
  'agave': 'agave syrup',
  'agave nectar': 'agave syrup',
  'bacon': 'cured pork bacon',
  'canned tomato': 'red ripe canned tomato',
  'ground beef': '80 20 ground beef',
  'brown sugar': 'brown sugar',
  'cheese': 'cheddar cheese',
  'coffee': 'brewed tap water coffee',
  'cornmeal': 'whole grain yellow cornmeal',
  'egg': 'whole egg',
  'flour': 'wheat white all purpose flour',
  'ginger': 'ginger root',
  'grape': 'red seedless grape',
  'light brown sugar': 'brown sugar',
  'dark brown sugar': 'brown sugar',
  'milk': 'whole milk',
  'mozzarella': 'whole milk mozzarella',
  'mozzarella cheese': 'whole milk mozzarella cheese',
  'mushroom': 'white mushroom',
  'oil': 'salad cooking soybean oil',
  'olive oil': 'salad cooking olive oil',
  'pasta': 'dry enriched pasta',
  'pea': 'green pea',
  'frozen pea': 'frozen green pea',
  'salmon': 'atlantic farmed salmon',
  'salt': 'table salt',
  'spaghetti': 'pasta dry enriched spaghetti',
  'sugar': 'granulated sugar',
  'white sugar': 'granulated sugar',
  'tomato': 'red ripe tomato',
  'vegetable oil': 'salad cooking soybean oil',
  'zucchini': 'summer squash zucchini',
};
