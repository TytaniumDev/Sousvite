/// Turns what the user typed into an FTS5 match expression for
/// `recipe_search`, or null when there is nothing to search for.
///
/// Every word must match the start of a word in the title, an ingredient,
/// or a folder name, so "chick tikka" finds "Chicken tikka masala". Words
/// are quoted, so FTS5 operators and punctuation are searched as text.
String? recipeSearchMatch(String query) {
  final words = query
      .split(RegExp(r'\s+'))
      .map((word) => word.replaceAll('"', ''))
      .where((word) => word.isNotEmpty);
  if (words.isEmpty) return null;
  return words.map((word) => '"$word"*').join(' ');
}
