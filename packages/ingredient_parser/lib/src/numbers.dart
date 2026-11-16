import 'package:domain/domain.dart';

/// Unicode fraction characters and their values.
const unicodeFractions = <String, (int, int)>{
  '½': (1, 2),
  '⅓': (1, 3),
  '⅔': (2, 3),
  '¼': (1, 4),
  '¾': (3, 4),
  '⅕': (1, 5),
  '⅖': (2, 5),
  '⅗': (3, 5),
  '⅘': (4, 5),
  '⅙': (1, 6),
  '⅚': (5, 6),
  '⅛': (1, 8),
  '⅜': (3, 8),
  '⅝': (5, 8),
  '⅞': (7, 8),
};

/// The Unicode fraction characters, for use inside a regex class.
final String fractionChars = unicodeFractions.keys.join();

/// A number written with digits: "1-1/2", "1 1/2", "1½", "1/2", "1.5",
/// ".5", "2", or "½". Never followed by more of a number, so "100g"
/// matches "100".
final String numberPattern =
    r'(?:\d+\s*-\s*\d+/\d+(?!\d)|\d+\s+\d+\s*[/⁄]\s*\d+'
    '|\\d+\\s*[$fractionChars]|\\d+\\s*[/⁄]\\s*\\d+|\\d*\\.\\d+|\\d+'
    '|[$fractionChars])'
    r'(?![\d⁄/]|\.\d)';

/// Number words, longer forms first so "a dozen" wins over "a".
const _numberWords = [
  'half an?',
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine',
  'ten',
  'eleven',
  'twelve',
  'a dozen',
  'dozen',
  'a half',
  'half',
  'an',
  'a',
];

/// A number written as words: "one", "a dozen", "half a".
final String wordNumberPattern = '(?:${_numberWords.join('|')})';

const _wordNumbers = <String, (int, int)>{
  'one': (1, 1),
  'two': (2, 1),
  'three': (3, 1),
  'four': (4, 1),
  'five': (5, 1),
  'six': (6, 1),
  'seven': (7, 1),
  'eight': (8, 1),
  'nine': (9, 1),
  'ten': (10, 1),
  'eleven': (11, 1),
  'twelve': (12, 1),
  'a': (1, 1),
  'an': (1, 1),
  'half': (1, 2),
  'a half': (1, 2),
  'half a': (1, 2),
  'half an': (1, 2),
  'a dozen': (12, 1),
  'dozen': (12, 1),
};

final _hyphenMixed = RegExp(r'^(\d+)\s*-\s*(\d+)/(\d+)$');
final _spacedMixed = RegExp(r'^(\d+)\s+(\d+)\s*/\s*(\d+)$');
final _unicodeMixed = RegExp('^(\\d*)\\s*([$fractionChars])\$');
final _fraction = RegExp(r'^(\d+)\s*/\s*(\d+)$');
final _decimal = RegExp(r'^(\d*)\.(\d+)$');
final _whole = RegExp(r'^\d+$');

/// The value of a number matched by [numberPattern] or
/// [wordNumberPattern], exactly.
Quantity parseNumber(String text) {
  final number = text.trim().replaceAll('⁄', '/');
  if (_hyphenMixed.firstMatch(number) ?? _spacedMixed.firstMatch(number)
      case final mixed?) {
    return Quantity(int.parse(mixed[1]!)) +
        Quantity(int.parse(mixed[2]!), int.parse(mixed[3]!));
  }
  if (_unicodeMixed.firstMatch(number) case final unicode?) {
    final (numerator, denominator) = unicodeFractions[unicode[2]]!;
    final whole = unicode[1]!.isEmpty ? 0 : int.parse(unicode[1]!);
    return Quantity(whole) + Quantity(numerator, denominator);
  }
  if (_fraction.firstMatch(number) case final fraction?) {
    return Quantity(int.parse(fraction[1]!), int.parse(fraction[2]!));
  }
  if (_decimal.firstMatch(number) case final decimal?) {
    final digits = decimal[2]!;
    var scale = 1;
    for (var i = 0; i < digits.length; i++) {
      scale *= 10;
    }
    return Quantity(int.parse('${decimal[1]}$digits'), scale);
  }
  if (_whole.hasMatch(number)) return Quantity(int.parse(number));
  final (numerator, denominator) =
      _wordNumbers[number.toLowerCase().replaceAll(RegExp(r'\s+'), ' ')]!;
  return Quantity(numerator, denominator);
}
