import 'package:domain/domain.dart';
import 'package:measuring/src/step_text/step_part.dart';

/// Smart step text for a whole recipe: each ingredient's amount is placed
/// at its first mention in the recipe, so later steps that say "the
/// onion" again stay as written (ENGINEERING.md §13).
///
/// See [smartStepText] for how mentions are found.
List<List<StepPart>> smartSteps(
  List<String> steps,
  List<IngredientLine> lines, {
  Quantity scale = Quantity.one,
}) {
  final mentioned = <IngredientLineId>{};
  return [
    for (final step in steps) _smartStepText(step, lines, scale, mentioned),
  ];
}

/// Finds the ingredients mentioned in [step] and places each one's amount,
/// multiplied by [scale], inline: "Add the garlic" becomes "Add **6**
/// garlic cloves" for the line "3 garlic cloves" at double size.
///
/// A mention is the line's name, the end of its name ("oats" for "rolled
/// oats"), or one of its alternatives ("butter" for "butter or ghee"),
/// with singular and plural treated alike. Longer matches win, and a short
/// form that fits two lines ("pepper" for "black pepper" and "red bell
/// pepper") is left alone. A leading "the" or "your" is replaced along
/// with the mention.
///
/// Only the first mention of each line gets its amount. A mention that
/// already has an amount ("2 cups flour"), is part of an amount ("half
/// the flour", "the remaining flour"), or names something made from the
/// ingredient ("the flour mixture") is left as written. Lines without a
/// quantity, such as "salt to taste", are never placed.
List<StepPart> smartStepText(
  String step,
  List<IngredientLine> lines, {
  Quantity scale = Quantity.one,
}) => _smartStepText(step, lines, scale, {});

/// Words before a mention that mean it is only part of the line's amount,
/// or that the step already gives the amount.
const _partWords = {
  'remaining',
  'reserved',
  'rest',
  'remainder',
  'half',
  'some',
  'more',
  'other',
  'leftover',
  'extra',
  'additional',
  'another',
};

/// Words after a mention that mean the step names something made from the
/// ingredient: "the flour mixture", "the pasta water".
const _madeFromWords = {
  'mixture',
  'mix',
  'batter',
  'dough',
  'sauce',
  'water',
  'juice',
  'zest',
  'powder',
  'paste',
  'stock',
  'broth',
  'liquid',
  'marinade',
  'dressing',
  'glaze',
};

/// Words that describe an ingredient but never name it on their own, so
/// "red" alone does not stand for "red onion".
const _describingWords = {
  'fresh',
  'dried',
  'ground',
  'chopped',
  'minced',
  'diced',
  'sliced',
  'grated',
  'large',
  'small',
  'medium',
  'whole',
  'raw',
  'cooked',
  'frozen',
  'canned',
  'unsalted',
  'salted',
  'extra',
  'virgin',
  'light',
  'dark',
  'red',
  'green',
  'yellow',
  'white',
  'black',
  'sweet',
  'hot',
  'mild',
  'plain',
  'fine',
  'coarse',
  'organic',
  'ripe',
  'packed',
  'softened',
  'melted',
  'cold',
  'warm',
  'boneless',
  'skinless',
  'purpose',
};

/// Count words at the end of a name that are not the ingredient itself:
/// "garlic cloves" is mentioned as "garlic".
const _countWords = {
  'clove',
  'sprig',
  'stalk',
  'stick',
  'head',
  'leaf',
  'leave',
  'slice',
  'piece',
  'can',
  'bunch',
  'fillet',
  'strip',
  'cube',
  'sheet',
};

/// Words that name an ingredient but are more often a cooking verb in a
/// step, so "roast" alone does not stand for "chuck roast".
const _cookingVerbs = {
  'roast',
  'mix',
  'rub',
  'dip',
  'spread',
  'glaze',
  'dressing',
  'crumble',
  'mash',
  'puree',
  'purée',
};

/// Joining words that split a name into alternatives.
const _alternativeWords = {'or', 'and'};

const _articles = {'the', 'your'};

final _wordPattern = RegExp(r"[\p{L}\p{N}][\p{L}\p{N}']*", unicode: true);

/// What may sit between two words of one mention: spaces, hyphens, and
/// commas ("boneless, skinless").
final _innerGap = RegExp(r'^[\s,\-‐–]+$');

/// A word that is an amount: "2", "1½", "½", "1/2", "1.5".
final _numberWord = RegExp(r'^[\d½⅓⅔¼¾⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞]');

final class _Word(final String text, final int start, final int end) {
  String get stem => _stem(text.toLowerCase());
}

/// A way to mention a line: its words' stems, and whether it is the whole
/// name.
final class _Phrase(final IngredientLine line, final bool isWholeName);

final class _Match(
  final IngredientLine line,
  final int firstWord,
  final int wordCount,
);

List<StepPart> _smartStepText(
  String step,
  List<IngredientLine> lines,
  Quantity scale,
  Set<IngredientLineId> mentioned,
) {
  final phrases = _phraseIndex(lines);
  final words = [
    for (final match in _wordPattern.allMatches(step))
      _Word(match.group(0)!, match.start, match.end),
  ];
  final matches = _matches(words, step, phrases);

  final parts = <StepPart>[];
  var cursor = 0;
  for (final match in matches) {
    final line = match.line;
    if (!mentioned.add(line.id)) continue;
    if (_isPartOrMadeFrom(words, match, step)) continue;

    final first = words[match.firstWord];
    final last = words[match.firstWord + match.wordCount - 1];
    final article = match.firstWord > 0 ? words[match.firstWord - 1] : null;
    final start =
        article != null &&
            _articles.contains(article.text.toLowerCase()) &&
            _innerGap.hasMatch(step.substring(article.end, first.start))
        ? article.start
        : first.start;

    if (start > cursor) parts.add(StepWords(step.substring(cursor, start)));
    parts.add(
      StepMention(
        lineId: line.id,
        original: step.substring(start, last.end),
        amount: Amount(line.quantity! * scale, line.unit),
        amountMax: line.quantityMax == null ? null : line.quantityMax! * scale,
        countWord: line.countWord,
        name: _displayName(line.name!.trim(), first.text),
      ),
    );
    cursor = last.end;
  }
  if (cursor < step.length) parts.add(StepWords(step.substring(cursor)));
  return parts;
}

/// Every phrase that mentions a line, keyed by its stems. A short form
/// shared by two lines is dropped unless it is one line's whole name.
Map<String, IngredientLine> _phraseIndex(List<IngredientLine> lines) {
  final byKey = <String, List<_Phrase>>{};
  for (final line in lines) {
    final name = line.name?.trim() ?? '';
    if (line.quantity == null || name.isEmpty) continue;
    for (final (key, isWholeName) in _phrasesOf(name)) {
      final phrases = byKey.putIfAbsent(key, () => []);
      if (!phrases.any((phrase) => phrase.line.id == line.id)) {
        phrases.add(_Phrase(line, isWholeName));
      }
    }
  }
  return {
    for (final MapEntry(:key, value: phrases) in byKey.entries)
      key: ?_owner(phrases),
  };
}

/// The line a phrase belongs to: the only one, or the one whose whole name
/// it is.
IngredientLine? _owner(List<_Phrase> phrases) {
  if (phrases.length == 1) return phrases.single.line;
  final whole = phrases.where((phrase) => phrase.isWholeName).toList();
  return whole.length == 1 ? whole.single.line : null;
}

/// The phrases that mention [name], as stem keys, each with whether it is
/// the whole name.
Iterable<(String, bool)> _phrasesOf(String name) sync* {
  final words = _wordPattern
      .allMatches(
        name.replaceAll(RegExp(r'\([^)]*\)'), ' ').replaceAll('/', ' or '),
      )
      .map((match) => _stem(match.group(0)!.toLowerCase()))
      .toList();
  if (words.isEmpty) return;
  yield (words.join(' '), true);

  var part = <String>[];
  for (final word in [...words, 'or']) {
    if (!_alternativeWords.contains(word)) {
      part.add(word);
      continue;
    }
    if (part.length > 1 && _countWords.contains(part.last)) {
      part = part.sublist(0, part.length - 1);
    }
    for (var start = 0; start < part.length; start++) {
      final suffix = part.sublist(start);
      if (suffix.length == 1 &&
          (_describingWords.contains(suffix.single) ||
              _countWords.contains(suffix.single) ||
              _cookingVerbs.contains(suffix.single) ||
              suffix.single.length < 3)) {
        continue;
      }
      yield (suffix.join(' '), false);
    }
    part = [];
  }
}

/// The mentions in [words], longest first, then in step order, without
/// overlaps, returned in step order.
List<_Match> _matches(
  List<_Word> words,
  String step,
  Map<String, IngredientLine> phrases,
) {
  final longest = phrases.keys.fold(
    0,
    (most, key) => key.split(' ').length > most ? key.split(' ').length : most,
  );
  final found = <_Match>[];
  for (var first = 0; first < words.length; first++) {
    final stems = <String>[];
    for (var count = 1; count <= longest; count++) {
      final index = first + count - 1;
      if (index >= words.length) break;
      if (count > 1 && !_joinsMention(step, words[index - 1], words[index])) {
        break;
      }
      stems.add(words[index].stem);
      final line = phrases[stems.join(' ')];
      if (line != null) found.add(_Match(line, first, count));
    }
  }
  found.sort((a, b) {
    final byLength = b.wordCount.compareTo(a.wordCount);
    return byLength != 0 ? byLength : a.firstWord.compareTo(b.firstWord);
  });

  final taken = List.filled(words.length, false);
  final kept = <_Match>[];
  for (final match in found) {
    final range = List.generate(match.wordCount, (i) => match.firstWord + i);
    if (range.any((index) => taken[index])) continue;
    for (final index in range) {
      taken[index] = true;
    }
    kept.add(match);
  }
  return kept..sort((a, b) => a.firstWord.compareTo(b.firstWord));
}

/// Whether [before] and [after] can be two words of one mention: only
/// spaces or hyphens between them, or a comma after a describing word
/// ("boneless, skinless").
bool _joinsMention(String step, _Word before, _Word after) {
  final gap = step.substring(before.end, after.start);
  return _innerGap.hasMatch(gap) &&
      (!gap.contains(',') || _describingWords.contains(before.stem));
}

/// Whether the words around [match] say it is only part of the amount, has
/// an amount already, or names something made from the ingredient.
bool _isPartOrMadeFrom(List<_Word> words, _Match match, String step) {
  final next = match.firstWord + match.wordCount;
  if (next < words.length &&
      _madeFromWords.contains(words[next].stem) &&
      _innerGap.hasMatch(
        step.substring(words[next - 1].end, words[next].start),
      )) {
    return true;
  }
  // Up to three words back, within the sentence: "half of the flour", "2
  // cups of flour", "the remaining flour".
  for (var back = 1; back <= 3; back++) {
    final index = match.firstWord - back;
    if (index < 0) break;
    final word = words[index];
    if (RegExp('[.;:!?]')
        .hasMatch(step.substring(word.end, words[index + 1].start))) {
      break;
    }
    final lower = word.text.toLowerCase();
    if (_partWords.contains(lower) ||
        _numberWord.hasMatch(word.text) ||
        unitFromAlias(word.text) != null) {
      return true;
    }
  }
  return false;
}

/// [name] as shown in the step: lowercased at the start when the step
/// wrote the mention in lowercase and the line is only capitalized
/// ("Onion").
String _displayName(String name, String mention) {
  final capitalized =
      name.length > 1 &&
      name[0] != name[0].toLowerCase() &&
      name[1] == name[1].toLowerCase();
  final mentionLower = mention[0] == mention[0].toLowerCase();
  return capitalized && mentionLower
      ? name[0].toLowerCase() + name.substring(1)
      : name;
}

/// [word] without a plural ending, so "tomatoes" and "tomato" match.
String _stem(String word) {
  if (word.length > 4 && word.endsWith('ies')) {
    return '${word.substring(0, word.length - 3)}y';
  }
  if (word.length > 4 &&
      (word.endsWith('oes') ||
          word.endsWith('ches') ||
          word.endsWith('shes') ||
          word.endsWith('xes'))) {
    return word.substring(0, word.length - 2);
  }
  if (word.length > 3 && word.endsWith('s') && !word.endsWith('ss')) {
    return word.substring(0, word.length - 1);
  }
  return word;
}
