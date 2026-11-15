/// Turns food and ingredient names into comparable tokens.
///
/// Both sides of a match go through the same steps, so "Tomatoes, raw" and
/// "2 ripe tomatoes" share the token "tomato".
library;

/// Words that carry no meaning for matching.
const _stopWords = {
  'a',
  'about',
  'an',
  'and',
  'as',
  'at',
  'by',
  'for',
  'from',
  'in',
  'into',
  'of',
  'on',
  'or',
  'the',
  'to',
  'with',
};

/// Plurals the simple rules in [singular] get wrong.
const _irregularPlurals = {
  'halves': 'half',
  'leaves': 'leaf',
  'loaves': 'loaf',
};

/// Lowercase tokens of [text], singular, without punctuation or stop words.
/// "All-purpose flour, sifted" gives `[all, purpose, flour, sifted]`.
List<String> foodTokens(String text) => [
  for (final word in text.toLowerCase().split(RegExp('[^a-z0-9]+')))
    if (word.isNotEmpty && !_stopWords.contains(word)) singular(word),
];

/// A simple singular form, applied to both sides of a match, so it only has
/// to be consistent, not correct English: "berries" → "berry",
/// "tomatoes" → "tomato", "leaves" → "leaf", "eggs" → "egg".
String singular(String word) {
  if (_irregularPlurals[word] case final irregular?) return irregular;
  if (word.length <= 3) return word;
  if (word.endsWith('ies')) return '${word.substring(0, word.length - 3)}y';
  if (word.endsWith('oes')) return word.substring(0, word.length - 2);
  if (word.endsWith('ches') || word.endsWith('shes') || word.endsWith('xes')) {
    return word.substring(0, word.length - 2);
  }
  if (word.endsWith('s') &&
      !word.endsWith('ss') &&
      !word.endsWith('us') &&
      !word.endsWith('is')) {
    return word.substring(0, word.length - 1);
  }
  return word;
}
