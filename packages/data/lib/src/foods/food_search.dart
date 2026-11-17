import 'package:domain/domain.dart';

/// The words of a food search, lowercase, or empty when there is nothing
/// to search for.
List<String> foodSearchWords(String query) => [
  for (final word in query.toLowerCase().split(RegExp(r'[\s,]+')))
    if (word.isNotEmpty) word,
];

/// A `WHERE` clause matching foods whose name holds every one of [words],
/// with one `?` variable per word for [foodSearchPatterns].
String foodSearchWhere(List<String> words) =>
    words.map((_) => r"lower(name) LIKE ? ESCAPE '\'").join(' AND ');

/// The `LIKE` patterns for [foodSearchWhere], with `%` and `_` escaped.
List<String> foodSearchPatterns(List<String> words) => [
  for (final word in words)
    '%${word.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}')}%',
];

/// Orders [foods] best first for [words]: names that start with the first
/// word as a whole word, then with it as a prefix ("Buttermilk"), then the
/// rest. Within each, shorter names come first, since "Butter, salted"
/// fits "butter" better than "Butter, stick, salted". Ties keep generic
/// foods first, then sort by name.
List<Food> rankFoods(List<Food> foods, List<String> words) {
  final first = words.isEmpty ? '' : words.first;
  final wholeWord = RegExp('^${RegExp.escape(first)}(?![a-z])');
  int score(Food food) {
    final name = food.name.toLowerCase();
    if (wholeWord.hasMatch(name)) return 0;
    return name.startsWith(first) ? 1 : 2;
  }

  return [...foods]..sort(
    (a, b) => switch (score(a).compareTo(score(b))) {
      0 => switch (a.name.length.compareTo(b.name.length)) {
        0 => switch ((a.brand == null ? 0 : 1).compareTo(
          b.brand == null ? 0 : 1,
        )) {
          0 => a.name.compareTo(b.name),
          final order => order,
        },
        final order => order,
      },
      final order => order,
    },
  );
}
