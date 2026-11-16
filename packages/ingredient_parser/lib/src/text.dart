/// Invisible characters and emoji, which recipe sites sprinkle into lines.
final _invisible = RegExp('[​‌‍⁠﻿️\u{1F000}-\u{1FAFF}☀-➿]', unicode: true);
final _spaces = RegExp(r'\s+');
final _bullet = RegExp(r'^[-•*▢]\s*');

/// A dash between words used as a comma: "chicken – boneless". Not between
/// numbers, where it is a range ("1 – 2 teaspoons").
final _dashAsComma = RegExp(
  r'(?<![\d½⅓⅔¼¾⅛])\s+[—–-]\s+(?![\d½⅓⅔¼¾⅛])(?=[^()]*(?:\(|$))',
);
final _dashInParentheses = RegExp(r'\([^)]*\s[—–]\s');

/// [line] without emoji, invisible characters, bullets, or extra spaces,
/// and with dashes between words turned into commas.
String cleanLine(String line) {
  final text = line
      .replaceAll(_invisible, '')
      .replaceAll(' ', ' ')
      .replaceAll(_spaces, ' ')
      .trim()
      .replaceFirst(_bullet, '');
  return _dashInParentheses.hasMatch(text)
      ? text
      : text.replaceAll(_dashAsComma, ', ');
}

/// Describing words that can sit on both sides of a comma inside a name:
/// "boneless, skinless chicken".
const _adjective =
    '(?:boneless|skinless|bone-in|skin-on|skin-off|roasted|salted|unsalted'
    '|toasted)';
final _adjectiveBefore = RegExp('$_adjective\$', caseSensitive: false);
final _adjectiveAfter = RegExp('^\\s*$_adjective\\b', caseSensitive: false);

/// [text] split at its first comma outside parentheses, skipping commas
/// between describing words. The second part is null when there is no
/// such comma.
(String, String?) splitAtComma(String text) {
  var depth = 0;
  for (var i = 0; i < text.length; i++) {
    switch (text[i]) {
      case '(':
        depth++;
      case ')':
        if (depth > 0) depth--;
      case ',' when depth == 0:
        if (_adjectiveBefore.hasMatch(text.substring(0, i)) &&
            _adjectiveAfter.hasMatch(text.substring(i + 1))) {
          continue;
        }
        return (text.substring(0, i), text.substring(i + 1));
    }
  }
  return (text, null);
}
