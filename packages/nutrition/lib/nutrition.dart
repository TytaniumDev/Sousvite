/// Food matching, unit to gram conversion, and nutrition totals. See
/// ENGINEERING.md §11.
library;

export 'src/convert/density_table.dart';
export 'src/convert/gram_weight.dart';
export 'src/matching/food_match.dart';
export 'src/matching/food_matcher.dart';
export 'src/matching/match_vocabulary.dart' show standardSynonyms;
export 'src/matching/synonym_table.dart';
export 'src/online/fetched_food.dart';
export 'src/online/online_foods.dart';
export 'src/online/open_food_facts_client.dart';
export 'src/online/serving_text.dart';
export 'src/online/usda_branded_client.dart';
export 'src/totals/nutrition_totals.dart';
