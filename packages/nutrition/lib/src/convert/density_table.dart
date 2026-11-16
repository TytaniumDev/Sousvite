/// Grams per milliliter of common ingredients, for volumes the food's own
/// USDA portions don't cover (ENGINEERING.md §11.2).
///
/// Values are for the ingredient as usually measured: flour spooned and
/// leveled, brown sugar packed, cheese shredded. Sources: USDA portion
/// weights and the King Arthur ingredient weight chart, rounded to two
/// places.
const Map<String, double> standardDensities = {
  'almond flour': 0.41,
  'baking powder': 0.81,
  'baking soda': 0.97,
  'bread flour': 0.54,
  'broth': 1,
  'brown sugar': 0.93,
  'butter': 0.96,
  'buttermilk': 1.03,
  'cake flour': 0.48,
  'cheese': 0.47,
  'chocolate chip': 0.72,
  'cocoa': 0.36,
  'coconut milk': 0.98,
  'corn syrup': 1.38,
  'cornmeal': 0.65,
  'cornstarch': 0.54,
  'cream': 1,
  'cream cheese': 0.97,
  'flour': 0.53,
  'honey': 1.42,
  'juice': 1.04,
  'ketchup': 1.15,
  'kosher salt': 0.54,
  'lentil': 0.81,
  'maple syrup': 1.32,
  'mayonnaise': 0.95,
  'milk': 1.03,
  'molasses': 1.4,
  'mustard': 1.05,
  'oat': 0.38,
  'oil': 0.92,
  'parmesan': 0.42,
  'peanut butter': 1.09,
  'powdered sugar': 0.51,
  'quinoa': 0.72,
  'rice': 0.85,
  'salt': 1.22,
  'sour cream': 0.97,
  'soy sauce': 1.15,
  'stock': 1,
  'sugar': 0.85,
  'tomato paste': 1.1,
  'tomato sauce': 1.03,
  'vinegar': 1.01,
  'water': 1,
  'whole wheat flour': 0.51,
  'wine': 0.99,
  'yeast': 0.65,
  'yogurt': 1.03,
};

/// Grams per milliliter of the ingredient [name], from [table], or null
/// when no entry matches.
///
/// Entries match whole words, ignoring case, punctuation, and a plural
/// "s", and the longest entry wins: "packed brown sugar" is brown sugar,
/// not sugar, and "Wheat flour, whole-grain" is flour.
double? densityOf(
  String name, {
  Map<String, double> table = standardDensities,
}) {
  final words = ' ${_words(name)} ';
  double? best;
  var bestLength = 0;
  for (final MapEntry(:key, :value) in table.entries) {
    final phrase = _words(key);
    if (phrase.length > bestLength && words.contains(' $phrase ')) {
      best = value;
      bestLength = phrase.length;
    }
  }
  return best;
}

String _words(String text) => text
    .toLowerCase()
    .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
    .where((word) => word.isNotEmpty)
    .map(
      (word) => word.length > 3 && word.endsWith('s') && !word.endsWith('ss')
          ? word.substring(0, word.length - 1)
          : word,
    )
    .join(' ');
