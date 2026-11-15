import 'package:domain/domain.dart';
import 'package:nutrition/src/matching/food_match.dart';
import 'package:nutrition/src/matching/food_text.dart';
import 'package:nutrition/src/matching/match_vocabulary.dart';
import 'package:nutrition/src/matching/synonym_table.dart';

/// Matches ingredient names to foods (ENGINEERING.md §11.2).
///
/// Matching is deterministic: the ingredient name is normalized, rewritten
/// with a [SynonymTable], and compared with each food's name by token
/// overlap. Generic USDA foods win over branded and Open Food Facts foods.
///
/// Build one matcher per set of candidate foods and reuse it: it tokenizes
/// every food once.
final class FoodMatcher(
  /// The foods to choose from.
  Iterable<Food> foods, {

  /// Rewrites cooks' words into USDA's before matching. Defaults to
  /// [standardSynonyms].
  SynonymTable? synonyms,
}) {
  final SynonymTable _synonyms = synonyms ?? standardSynonyms;

  final List<_IndexedFood> _foods = [
    for (final food in foods) _IndexedFood.from(food),
  ];

  /// The smallest share of an ingredient's words a food must cover to be
  /// matched without asking the user.
  static const minimumCoverage = 0.6;

  /// The best food for [ingredientName], or [FoodUnmatched] when none
  /// covers enough of the name.
  FoodMatch match(String ingredientName) {
    final best = rank(ingredientName, limit: 1).firstOrNull;
    return best == null
        ? const FoodUnmatched()
        : FoodMatched(food: best.food, score: best.score);
  }

  /// Foods for [ingredientName], best first, at most [limit] of them. Only
  /// foods that contain the name's main word and cover at least
  /// [minimumCoverage] of it are included. The app shows these when the
  /// user changes a match.
  List<RankedFood> rank(String ingredientName, {int limit = 10}) {
    final query = _Query(_synonyms.apply(foodTokens(ingredientName)));
    if (query.tokens.isEmpty) return const [];
    final ranked = [
      for (final food in _foods)
        if (food.scoreFor(query) case final score?)
          RankedFood(food: food.food, score: score),
    ]..sort(_compare);
    return ranked.take(limit).toList();
  }

  /// Best score first; ties go to the shorter name, then the lower id, so
  /// the result never depends on the order of the candidates.
  static int _compare(RankedFood a, RankedFood b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    final byLength = a.food.name.length.compareTo(b.food.name.length);
    if (byLength != 0) return byLength;
    return a.food.id.value.compareTo(b.food.id.value);
  }
}

/// An ingredient name prepared for matching.
final class _Query(
  /// The name's tokens after synonyms, in order.
  final List<String> tokens,
) {
  late final Set<String> set = tokens.toSet();

  /// The main word: in English ingredient names, the last one
  /// ("all-purpose flour", "unsalted butter").
  String get head => tokens.last;

  /// Each word counts once, the main word twice.
  late final double totalWeight = set.length + 1.0;
}

/// A food with its name tokenized once.
final class const _IndexedFood._(
  final Food food,
  final Set<String> tokens,
  final Set<String> identity,
) {
  factory from(Food food) {
    final segments = food.name.split(',').map(foodTokens).toList();
    // USDA names start with what the food is ("Garlic, raw"), sometimes
    // after a category word ("Spices, pepper, black").
    final identity = segments
        .firstWhere(
          (s) => s.isNotEmpty && !s.every(categoryWords.contains),
          orElse: () => const [],
        )
        .toSet();
    return _IndexedFood._(food, segments.expand((s) => s).toSet(), identity);
  }

  bool get _isGeneric =>
      food.source == NutritionSource.usda && food.brand == null;

  /// How well this food fits [query], or null when it doesn't contain the
  /// main word or covers too little of the name.
  double? scoreFor(_Query query) {
    if (!tokens.contains(query.head)) return null;
    final matched = query.set.where(tokens.contains);
    final coverage = (matched.length + 1) / query.totalWeight;
    if (coverage < FoodMatcher.minimumCoverage) return null;

    var penalty = 0.0;
    for (final token in tokens) {
      if (query.set.contains(token) || neutralWords.contains(token)) continue;
      penalty += unwantedWords[token] ?? extraWordPenalty;
    }
    final identityBonus =
        identity.isNotEmpty && identity.every(query.set.contains)
        ? identityMatchBonus
        : 0;
    return 100 * coverage +
        identityBonus -
        penalty -
        (_isGeneric ? 0 : nonGenericPenalty);
  }
}
