/// The English plural of a count word such as "clove" or "bunch", for
/// showing after an amount above one: "2 cloves", "3 bunches", "2 leaves".
///
/// Count words are kept as text (ENGINEERING.md §12), so this follows the
/// regular spelling rules plus the irregular words recipes use.
String pluralOf(String word) {
  final irregular = _irregular[word];
  if (irregular != null) return irregular;
  if (_sibilantEnding.hasMatch(word)) return '${word}es';
  if (_consonantY.hasMatch(word)) {
    return '${word.substring(0, word.length - 1)}ies';
  }
  return '${word}s';
}

/// Words whose plural changes the stem: "leaf" becomes "leaves".
const _irregular = {
  'half': 'halves',
  'knife': 'knives',
  'leaf': 'leaves',
  'loaf': 'loaves',
};

/// Endings that take "es": "bunch", "dash", "box", "glass", "spritz".
final _sibilantEnding = RegExp(r'(s|x|z|ch|sh)$');

/// A "y" after a consonant becomes "ies": "berry" but not "tray".
final _consonantY = RegExp(r'[^aeiou]y$');
