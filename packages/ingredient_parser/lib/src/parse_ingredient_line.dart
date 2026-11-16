import 'package:domain/domain.dart';
import 'package:ingredient_parser/src/numbers.dart';
import 'package:ingredient_parser/src/parsed_amount.dart';
import 'package:ingredient_parser/src/parsed_line.dart';
import 'package:ingredient_parser/src/text.dart';
import 'package:ingredient_parser/src/units.dart';

/// Splits an ingredient [line] into its parts (ENGINEERING.md §12):
///
/// ```text
/// "1 ½ cups rolled oats, chopped"
///   → quantity 3/2, unit cup, name "rolled oats", preparation "chopped"
/// ```
///
/// Understands Unicode and ASCII fractions, mixed numbers, decimals,
/// number words, ranges, US and metric units and their abbreviations,
/// count words ("3 cloves garlic"), sizes ("1 large egg"), container sizes
/// ("1 (15 oz) can"), the same amount in another unit ("1 cup (240 ml)"),
/// lines with no amount ("Salt to taste"), and section headings ("For the
/// sauce:"). The rules and the corpus it is measured against are in
/// `test/fixtures/README.md`.
ParsedLine parseIngredientLine(String line) {
  final text = cleanLine(line);
  final heading = _heading(text);
  if (heading != null) return ParsedLine(text: line, heading: heading);
  return (_Parts(text)..parse()).toParsedLine(line);
}

const _sizes = [
  'extra-large',
  'extra large',
  'medium-sized',
  'medium sized',
  'medium-size',
  'medium-large',
  'small',
  'medium',
  'large',
  'jumbo',
  'big',
  'mini',
  'giant',
  'heaping',
  'heaped',
  'level',
  'scant',
  'generous',
];

/// Size words that describe the amount, not the item: "1 heaping
/// tablespoon". They go in the preparation.
const _amountModifiers = {'heaping', 'heaped', 'level', 'scant', 'generous'};

const _trailingNotes = [
  'for deep frying',
  'for garnishing',
  'for brushing',
  'for coating',
  'for seasoning',
  'or more to taste',
  'or to taste',
  'to taste',
  'or as needed',
  'as needed',
  'for serving',
  'for garnish',
  'to serve',
  'for topping',
  'for drizzling',
  'for dusting',
  'for frying',
  'for greasing',
];

const _prepWord =
    '(?:(?:finely|thinly|roughly|coarsely|freshly|lightly|very|well|thickly'
    r'|loosely|firmly)\s+)?'
    '(?:minced|chopped|diced|sliced|grated|melted|softened|crushed|peeled'
    '|drained|rinsed|divided|shredded|cubed|beaten|juiced|zested|halved'
    '|quartered|mashed|toasted|sifted|trimmed|pitted|cooked|cooled|squeezed'
    '|julienned|torn|smashed|packed|room temperature)';

final _forHeading = RegExp(r'^for (?:the )?(.+?):?$', caseSensitive: false);
final _digit = RegExp(r'\d');
final _optional = RegExp(
  r'^((?:totally\s+)?optional)(?:\s*[:\-–]\s*|\s+(?![,(]))',
  caseSensitive: false,
);
final _approximately = RegExp(
  r'^(?:about|approximately|approx\.?|around|~)\s*',
  caseSensitive: false,
);
final _approximatelyInParentheses = RegExp(
  r'^(?:about|approximately|approx\.?|roughly|around|~)\s*',
  caseSensitive: false,
);
final _leadingModifier = RegExp(
  '^(scant|heaping|heaped|generous|level)\\s+(?=$numberPattern)',
  caseSensitive: false,
);
final _juiceOf = RegExp(
  r'^((?:[\w-]+\s+){0,2}?(?:juice|zest|rind)(?:\s*(?:and|&)\s*(?:juice|zest))?)'
  r'\s+(?:of|from)\s+',
  caseSensitive: false,
);
final _sizedPiece = RegExp(
  '^($numberPattern\\s*-?\\s*(?:cm|inch|in\\.|")(?:-thick)?)\\s+'
  r'(piece|knob|chunk)s?\s+(?:of\s+)?',
  caseSensitive: false,
);
final _plusFraction = RegExp(
  '^(\\d+)\\s*(?:\\+|and)\\s*(\\d+/\\d+|[$fractionChars])\\s+',
);
final _andAHalf = RegExp(
  '^($numberPattern|$wordNumberPattern)\\s+and\\s+a\\s+half(?![A-Za-z])\\s*',
  caseSensitive: false,
);
final _amount = RegExp(
  '^($numberPattern|$wordNumberPattern(?![A-Za-z]))\\s*',
  caseSensitive: false,
);
final _digitsAmount = RegExp('^($numberPattern)\\s*');
final _rangeEnd = RegExp('^(?:-|–|—|to|or)\\s*($numberPattern)\\s*');
final _dashLength = RegExp(r'^-\s*(?:inch|in\b|cm)');
final _times = RegExp(r'^[x×]\s');
final _sizeInParentheses = RegExp(
  '^\\(\\s*($numberPattern(?:\\s*-?\\s*(?:to|-)\\s*$numberPattern)?'
  r'\s*-?\s*(?:inch|in\.|cm))\s*\)\s*',
);

/// An amount with a unit word: "(15 oz)", "(14.5-ounce)", "15oz ".
String _measureIn(String open, String close) =>
    '^$open($numberPattern)\\s*-?\\s*(?:(?:to|-)\\s*($numberPattern)\\s*-?\\s*)?'
    '(fl\\.?\\s*oz|[A-Za-z]+)\\.?$close';
final _packageInParentheses = RegExp(_measureIn(r'\(\s*', r'\s*\)\s*'));
final _packageInline = RegExp(_measureIn('', r'\s+'));
final _packed = RegExp(
  r'^(\(?(?:tightly\s+|loosely\s+|firmly\s+)?packed\)?)\s+',
  caseSensitive: false,
);
final _smallAmount = RegExp(
  r'^(?:a\s+)?(?:(big|small|large|generous)\s+)?(pinch|dash|handful|splash)'
  r'(?:es|s)?\s+(?:of\s+)?',
  caseSensitive: false,
);
final _plus = RegExp(r'^(?:plus|\+)\s+', caseSensitive: false);
final _parenthesesAtStart = RegExp(r'^\(([^()]*)\)\s*');
final _alternateStart = RegExp(
  r'^(?:/|\(\s*(?:about|approximately|approx\.?|~)?\s*)',
);
final _of = RegExp(r'^of\s+', caseSensitive: false);
final _parentheses = RegExp(r'\(([^()]*)\)');
final _spaces = RegExp(r'\s+');
final _note = RegExp(r'\s*(\*.*)$');
final _plusMore = RegExp(r'\s+(\+\s*(?:\d|additional|extra|more).*)$');
final _plusInName = RegExp(r'\s+(plus\s.*)$', caseSensitive: false);
final _trailingPrep = RegExp(
  '\\s+($_prepWord(?:\\s+(?:and|or)\\s+$_prepWord)?)\$',
  caseSensitive: false,
);
final _notName = RegExp(
  '^(?:such|like|plus|for|about|approx|cut|to|at|in|into|with|without|from'
  '|preferably|optional|divided|if|see|more|or more|or to|or as|as|room|use'
  r'|can|\d|or use\b|[a-z]+ed\b|[a-z]+ly\b|or\s+[a-z]+ed\b|or\s+\d'
  r'|or\s+(?:more|less|to|as|other)\b)(?![a-z])',
  caseSensitive: false,
);
final _pastTense = RegExp(r'\b(?!red\b|seed\b|shred\b)\w+ed\b');
final _orWord = RegExp(r'(?:^|\s)or\s');
final _spaceBeforeComma = RegExp(r'\s+,');
final _edgeCommas = RegExp(r'^[\s,]+|[\s,]+$');

/// The title of a heading line: "For the sauce:", "Dressing:".
String? _heading(String text) {
  if (_digit.hasMatch(text)) return null;
  final forThe = _forHeading.firstMatch(text);
  if (forThe != null) return forThe[1]!.trim();
  if (text.endsWith(':') && text.split(' ').length <= 5) {
    return text.substring(0, text.length - 1).trim();
  }
  return null;
}

/// An amount and its range end at the start of [text], and the text after.
(Quantity, Quantity?, String)? _amountAt(String text, {bool words = true}) {
  final match = (words ? _amount : _digitsAmount).firstMatch(text);
  if (match == null) return null;
  final first = parseNumber(match[1]!);
  final rest = text.substring(match.end);
  final range = _rangeEnd.firstMatch(rest);
  if (range != null && !_dashLength.hasMatch(rest)) {
    return (first, parseNumber(range[1]!), rest.substring(range.end));
  }
  return (first, null, rest);
}

/// An amount in a measuring unit at the start of [text], such as "150
/// grams", and the text after it.
(ParsedAmount, String)? _measureAt(String text) {
  final amount = _amountAt(text, words: false);
  if (amount == null) return null;
  final (quantity, quantityMax, rest) = amount;
  final unit = unitAt(rest.replaceFirst(RegExp(r'^-\s*'), ''));
  if (unit == null || !isMeasure(unit.unit)) return null;
  return (
    ParsedAmount(
      quantity: quantity,
      quantityMax: quantityMax,
      unit: unit.unit!,
    ),
    unit.rest,
  );
}

/// A parenthetical that is an amount, such as "about 3/4 cup, loosely
/// packed", as the amount and any note after it.
(ParsedAmount, String?)? _measureInParentheses(String text) {
  final measure = _measureAt(
    text.replaceFirst(_approximatelyInParentheses, ''),
  );
  if (measure == null) return null;
  final (amount, rest) = measure;
  final note = rest.trim();
  if (note.isEmpty) return (amount, null);
  if (note.startsWith(',') || note.startsWith(';')) {
    return (amount, note.substring(1).trim());
  }
  return null;
}

/// The parts of a line as they are found, in the order the rules run.
final class _Parts(final String _cleaned) {
  late String _rest = _cleaned;
  Quantity? _quantity;
  Quantity? _quantityMax;
  Unit? _unit;
  String? _countWord;
  ParsedAmount? _package;
  ParsedAmount? _alternate;
  String? _size;
  String _name = '';
  final List<String> _preparation = [];

  bool get _hasUnit => _unit != null || _countWord != null;
  bool get _isContainer => containers.contains(_countWord);

  void parse() {
    _leadingNotes();
    _amount();
    _packageAndSize();
    _unitAfterAmount();
    _amountWithoutNumber();
    _takePlus();
    _alternateAfterUnit();
    _takePlus();
    _measuredContainer();
    if (_hasUnit) _rest = _rest.replaceFirst(_of, '');
    _sizeBeforeName();
    _nameAndNotes();
  }

  /// "Optional:", "about", and "juice of" before the amount.
  void _leadingNotes() {
    final optional = _optional.firstMatch(_rest);
    if (optional != null) {
      _preparation.add('optional');
      _rest = _rest.substring(optional.end);
    }
    _rest = _rest.replaceFirst(_approximately, '');
    final modifier = _leadingModifier.firstMatch(_rest);
    if (modifier != null) {
      _preparation.add(modifier[1]!);
      _rest = _rest.substring(modifier.end);
    }
    final juice = _juiceOf.firstMatch(_rest);
    if (juice != null) {
      _preparation.add(juice[1]!);
      _rest = _rest.substring(juice.end);
    }
  }

  void _amount() {
    final piece = _sizedPiece.firstMatch(_rest);
    if (piece != null) {
      _size = piece[1];
      _rest = '1 ${piece[2]} ${_rest.substring(piece.end)}';
    }
    final plus = _plusFraction.firstMatch(_rest);
    if (plus != null) {
      _rest = '${plus[1]} ${plus[2]} ${_rest.substring(plus.end)}';
    }
    final andAHalf = _andAHalf.firstMatch(_rest);
    if (andAHalf != null) {
      _quantity = parseNumber(andAHalf[1]!) + Quantity(1, 2);
      _rest = _rest.substring(andAHalf.end);
      return;
    }
    final amount = _amountAt(_rest);
    if (amount == null) return;
    final (quantity, quantityMax, rest) = amount;
    _quantity = quantity;
    _quantityMax = quantityMax;
    _rest = rest;
    if (_times.hasMatch(_rest)) _rest = _rest.substring(2);
  }

  /// "(2-inch)", "(15 oz) can", "15oz can".
  void _packageAndSize() {
    if (_quantity == null) return;
    final size = _sizeInParentheses.firstMatch(_rest);
    if (size != null) {
      _size = size[1];
      _rest = _rest.substring(size.end);
    }
    final package =
        _packageInParentheses.firstMatch(_rest) ??
        _packageInline.firstMatch(_rest);
    if (package == null) return;
    final unit = unitAt(package[3]!)?.unit;
    final container = unitAt(_rest.substring(package.end));
    if (isMeasure(unit) && container != null && !isMeasure(container.unit)) {
      _package = ParsedAmount(
        quantity: parseNumber(package[1]!),
        quantityMax: package[2] == null ? null : parseNumber(package[2]!),
        unit: unit!,
      );
      _unit = container.unit;
      _countWord = container.countWord;
      _rest = container.rest;
    }
  }

  void _unitAfterAmount() {
    if (_quantity == null || _hasUnit) return;
    final packed = _packed.firstMatch(_rest);
    if (packed != null) {
      final unit = unitAt(_rest.substring(packed.end));
      if (unit != null) {
        _preparation.add(packed[1]!.replaceAll(RegExp('[()]'), ''));
        _setUnit(unit);
        return;
      }
    }
    // A size or modifier before the unit: "2 large cloves", "1 heaping
    // tablespoon".
    for (final size in _sizes) {
      final match = RegExp(
        '^${RegExp.escape(size)}\\s+',
        caseSensitive: false,
      ).firstMatch(_rest);
      if (match == null) continue;
      final unit = unitAt(_rest.substring(match.end));
      if (unit != null) {
        final word = match[0]!.trim();
        if (_amountModifiers.contains(size)) {
          _preparation.add(word);
        } else {
          _size = word;
        }
        _setUnit(unit);
        return;
      }
      break;
    }
    final unit = unitAt(_rest);
    // A count word with nothing after it is the ingredient: "5 cloves".
    if (unit != null && (unit.countWord == null || unit.rest.isNotEmpty)) {
      _setUnit(unit);
    }
  }

  /// "a pinch of salt", "handful of spinach".
  void _amountWithoutNumber() {
    if (_quantity != null || _hasUnit) return;
    final match = _smallAmount.firstMatch(_rest);
    if (match == null) return;
    final unit = unitAt(match[2]!)!;
    _size = match[1];
    _quantity = Quantity.one;
    _unit = unit.unit;
    _countWord = unit.countWord;
    _rest = _rest.substring(match.end);
  }

  /// "plus 1 tablespoon (15 g)" after the unit goes in the preparation.
  void _takePlus() {
    final plus = _plus.firstMatch(_rest);
    if (plus == null || !_hasUnit) return;
    final measure = _measureAt(_rest.substring(plus.end));
    if (measure == null) return;
    var rest = measure.$2;
    var extra = '';
    final parentheses = _parenthesesAtStart.firstMatch(rest);
    if (parentheses != null) {
      extra = ', ${parentheses[1]}';
      rest = rest.substring(parentheses.end);
    }
    _preparation.add(
      _rest.substring(0, _rest.length - measure.$2.length).trim() + extra,
    );
    _rest = rest;
  }

  /// "/150 grams", "(240 ml)", "(about 4 cups)".
  void _alternateAfterUnit() {
    final start = _alternateStart.firstMatch(_rest);
    if (start == null || !_hasUnit) return;
    final measure = _measureAt(_rest.substring(start.end));
    if (measure == null) return;
    final (amount, after) = measure;
    final rest = after.trimLeft();
    if (!_rest.startsWith('(')) {
      _alternate = amount;
      _rest = rest;
    } else if (rest.startsWith(')')) {
      if (_isContainer) {
        _package = amount;
      } else {
        _alternate = amount;
      }
      _rest = rest.substring(1).trimLeft();
    } else if (rest.startsWith(',')) {
      _alternate = amount;
      final close = rest.indexOf(')');
      final inner = close < 0 ? rest.substring(1) : rest.substring(1, close);
      _preparation.add(inner.trim());
      _rest = close < 0 ? '' : rest.substring(close + 1).trimLeft();
    }
  }

  /// "15 oz can": a measure followed by a container is the container's
  /// size.
  void _measuredContainer() {
    if (!isMeasure(_unit) || _package != null || _alternate != null) return;
    final container = unitAt(_rest);
    if (!containers.contains(container?.countWord)) return;
    _package = ParsedAmount(
      quantity: _quantity!,
      quantityMax: _quantityMax,
      unit: _unit!,
    );
    _quantity = Quantity.one;
    _quantityMax = null;
    _unit = null;
    _countWord = container!.countWord;
    _rest = container.rest;
  }

  void _sizeBeforeName() {
    if (_size != null || isMeasure(_unit)) return;
    for (final size in _sizes) {
      if (_amountModifiers.contains(size) || size == 'mini') continue;
      final match = RegExp(
        '^${RegExp.escape(size)}\\s+',
        caseSensitive: false,
      ).firstMatch(_rest);
      if (match != null) {
        _size = match[0]!.trim();
        _rest = _rest.substring(match.end);
        return;
      }
    }
  }

  void _nameAndNotes() {
    var (name, afterComma) = splitAtComma(_rest);
    (name, afterComma) = _withAlternatives(name, afterComma);

    final parentheses = <String>[];
    name = name.replaceAllMapped(_parentheses, (match) {
      parentheses.add(match[1]!.trim());
      return ' ';
    });
    for (final note in parentheses) {
      _noteInParentheses(note, packageFirst: true);
    }
    name = name.replaceAll(_spaces, ' ').trim();

    for (final pattern in [_note, _plusMore, _plusInName]) {
      final match = pattern.firstMatch(name);
      if (match != null) {
        _preparation.add(match[1]!);
        name = name.substring(0, match.start);
      }
    }
    for (final note in _trailingNotes) {
      final match = RegExp(
        '\\s+(${RegExp.escape(note)})\$',
        caseSensitive: false,
      ).firstMatch(name);
      if (match != null) {
        _preparation.add(match[1]!);
        name = name.substring(0, match.start);
        break;
      }
    }
    final prep = _trailingPrep.firstMatch(name);
    if (prep != null) {
      _preparation.insert(0, prep[1]!);
      name = name.substring(0, prep.start);
    }

    if (afterComma != null) _tail(afterComma.trim());
    _name = _trimCommas(name.replaceAll(_spaceBeforeComma, ','));
  }

  /// A parenthetical: a container size, the amount in another unit, or a
  /// note.
  void _noteInParentheses(String note, {bool packageFirst = false}) {
    final measure = _measureInParentheses(note);
    if (measure != null && packageFirst && _isContainer && _package == null) {
      _package = measure.$1;
      if (measure.$2 != null) _preparation.add(measure.$2!);
    } else if (measure != null && _alternate == null) {
      _alternate = measure.$1;
      if (measure.$2 != null) _preparation.add(measure.$2!);
    } else {
      _preparation.add(note);
    }
  }

  /// Everything after the name's comma: preparation, notes, and sometimes
  /// the amount in another unit ("3 tbsp sugar, 36 grams").
  void _tail(String text) {
    var tail = text;
    final measure = _measureAt(tail);
    if (measure != null && measure.$2.trim().isEmpty && _alternate == null) {
      _alternate = measure.$1;
      tail = '';
    }
    if (tail.isEmpty) return;
    final parentheses = <String>[];
    tail = tail
        .replaceAllMapped(_parentheses, (match) {
          parentheses.add(match[1]!.trim());
          return '';
        })
        .replaceAll(_spaces, ' ')
        .trim();
    final kept = <String>[];
    for (final part in tail.split(',')) {
      final amount = _measureInParentheses(part.trim());
      if (amount != null && _alternate == null && amount.$2 == null) {
        _alternate = amount.$1;
      } else {
        kept.add(part);
      }
    }
    _preparation.add(kept.join(','));
    parentheses.forEach(_noteInParentheses);
  }

  void _setUnit(UnitMatch match) {
    _unit = match.unit;
    _countWord = match.countWord;
    _rest = match.rest;
  }

  ParsedLine toParsedLine(String line) {
    final parts = [
      for (final part in _preparation)
        for (final piece in part.split(','))
          if (piece.trim().isNotEmpty) piece.trim(),
    ];
    final lower = _cleaned.toLowerCase();
    final ordered = [
      for (final (index, part) in parts.indexed)
        (lower.indexOf(part.toLowerCase()), index, part),
    ]..sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2 - b.$2);
    return ParsedLine(
      text: line,
      quantity: _quantity,
      quantityMax: _quantityMax,
      unit: _unit,
      countWord: _countWord,
      package: _package,
      alternate: _alternate,
      size: _size,
      name: _name.isEmpty ? null : _name,
      preparation: ordered.isEmpty
          ? null
          : ordered.map((entry) => entry.$3).join(', '),
    );
  }
}

/// "coconut aminos, tamari, or soy sauce": a list of alternatives after
/// the first comma stays in the name.
(String, String?) _withAlternatives(String name, String? afterComma) {
  if (afterComma == null) return (name, afterComma);
  final parts = <String>[];
  String? rest = afterComma;
  while (rest != null && parts.length < 3) {
    final (part, next) = splitAtComma(rest);
    parts.add(part);
    rest = next;
    final clean = part.replaceAll(_parentheses, '').trim();
    if (clean.isEmpty ||
        _notName.hasMatch(clean) ||
        _pastTense.hasMatch(clean)) {
      return (name, afterComma);
    }
    if (_orWord.hasMatch(clean)) {
      return (
        '$name,${parts.join(',')}'.replaceAll(_spaceBeforeComma, ','),
        rest,
      );
    }
  }
  return (name, afterComma);
}

/// [text] without commas or spaces at either end.
String _trimCommas(String text) => text.replaceAll(_edgeCommas, '');
