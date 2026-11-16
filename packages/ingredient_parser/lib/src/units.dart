import 'package:domain/domain.dart';

/// A unit found at the start of some text: a measuring unit or a
/// count word, and the text after it.
typedef UnitMatch = ({Unit? unit, String? countWord, String rest});

/// Count words used as units, by every way they are written. The values
/// are the singular forms the parser reports (the corpus README lists
/// them).
const countWords = <String, String>{
  'can': 'can',
  'cans': 'can',
  'tin': 'can',
  'tins': 'can',
  'clove': 'clove',
  'cloves': 'clove',
  'slice': 'slice',
  'slices': 'slice',
  'stick': 'stick',
  'sticks': 'stick',
  'bunch': 'bunch',
  'bunches': 'bunch',
  'head': 'head',
  'heads': 'head',
  'sprig': 'sprig',
  'sprigs': 'sprig',
  'handful': 'handful',
  'handfuls': 'handful',
  'package': 'package',
  'packages': 'package',
  'pkg': 'package',
  'pkgs': 'package',
  'packet': 'packet',
  'packets': 'packet',
  'envelope': 'packet',
  'envelopes': 'packet',
  'sachet': 'packet',
  'sachets': 'packet',
  'dash': 'dash',
  'dashes': 'dash',
  'drop': 'drop',
  'drops': 'drop',
  'splash': 'splash',
  'splashes': 'splash',
  'jar': 'jar',
  'jars': 'jar',
  'tube': 'tube',
  'tubes': 'tube',
  'bag': 'bag',
  'bags': 'bag',
  'block': 'block',
  'blocks': 'block',
  'bottle': 'bottle',
  'bottles': 'bottle',
  'box': 'box',
  'boxes': 'box',
  'carton': 'carton',
  'cartons': 'carton',
  'container': 'container',
  'containers': 'container',
  'tub': 'container',
  'tubs': 'container',
  'stalk': 'stalk',
  'stalks': 'stalk',
  'rib': 'stalk',
  'ribs': 'stalk',
  'sheet': 'sheet',
  'sheets': 'sheet',
  'scoop': 'scoop',
  'scoops': 'scoop',
  'cube': 'cube',
  'cubes': 'cube',
  'fillet': 'fillet',
  'fillets': 'fillet',
  'filet': 'fillet',
  'filets': 'fillet',
  'strip': 'strip',
  'strips': 'strip',
  'ear': 'ear',
  'ears': 'ear',
  'knob': 'knob',
  'knobs': 'knob',
  'loaf': 'loaf',
  'loaves': 'loaf',
  'bulb': 'bulb',
  'bulbs': 'bulb',
  'leaf': 'leaf',
  'leaves': 'leaf',
  'inch': 'inch',
  'inches': 'inch',
};

/// Count words for containers, whose size can be given as a package
/// amount ("1 (15 oz) can").
const containers = {
  'can',
  'package',
  'packet',
  'jar',
  'tube',
  'bag',
  'block',
  'bottle',
  'box',
  'carton',
  'container',
};

/// Misspellings and forms `unitFromAlias` does not know.
const _extraAliases = <String, Unit>{
  'tb': .tablespoon,
  'teaspooon': .teaspoon,
  'tea spoon': .teaspoon,
  'tea spoons': .teaspoon,
  'tablesppon': .tablespoon,
};

final _twoWordUnit = RegExp(
  r'^(fl\.?\s*oz|fluid\s+ounces?|tea\s+spoons?)\.?(?![A-Za-z])\s*',
  caseSensitive: false,
);
final _oneWordUnit = RegExp(r'^([A-Za-z]+)\.?(?![A-Za-z])\s*');

/// The unit at the start of [text], if there is one.
UnitMatch? unitAt(String text) {
  for (final pattern in [_twoWordUnit, _oneWordUnit]) {
    final match = pattern.firstMatch(text);
    if (match == null) continue;
    final word = match[1]!;
    final rest = text.substring(match.end);
    final unit =
        unitFromAlias(word) ??
        _extraAliases[word.toLowerCase().replaceAll(RegExp(r'\s+'), ' ')];
    if (unit != null) return (unit: unit, countWord: null, rest: rest);
    final countWord = countWords[word.toLowerCase()];
    if (countWord != null) {
      return (unit: null, countWord: countWord, rest: rest);
    }
  }
  return null;
}

/// Whether [unit] measures volume or mass, as opposed to a count such as a
/// pinch.
bool isMeasure(Unit? unit) => unit != null && unit.family != .count;
