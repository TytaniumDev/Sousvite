/// The key grocery items are combined by, so "2 Onions" and "1 onion" land
/// on one line: lower case, punctuation as spaces, runs of spaces collapsed,
/// and each word reduced to a stem that a word's singular and plural share.
///
/// The stem is for matching only and is never shown, so it may not be a
/// real word ("berries" and "berry" both become "berry", "cookie" and
/// "cookies" both become "cooky").
String groceryKey(String name) => name
    .toLowerCase()
    .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
    .where((word) => word.isNotEmpty)
    .map(_stem)
    .join(' ');

String _stem(String word) {
  if (word.length <= 3) return word;
  if (word.endsWith('ies')) return '${_cut(word, 3)}y';
  if (word.endsWith('ie')) return '${_cut(word, 2)}y';
  if (word.endsWith('oes')) return _cut(word, 2);
  for (final ending in const ['ches', 'shes', 'sses', 'xes', 'zes']) {
    if (word.endsWith(ending)) return _cut(word, 2);
  }
  if (word.endsWith('s') && !_keepsS.any(word.endsWith)) {
    return _cut(word, 1);
  }
  return word;
}

/// Endings whose final "s" is not a plural: "glass", "asparagus", "pastis".
const _keepsS = ['ss', 'us', 'is'];

String _cut(String word, int count) => word.substring(0, word.length - count);
