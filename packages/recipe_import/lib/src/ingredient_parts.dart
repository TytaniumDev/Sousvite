import 'dart:math';

import 'package:domain/domain.dart';
import 'package:ingredient_parser/ingredient_parser.dart';

/// [line] with its amount, unit, name, and preparation filled in from
/// [parsed], the parser's reading of its raw text (ENGINEERING.md §12).
///
/// An ingredient line has no field for a count word or a size, so they stay
/// in the name as written: "3 cloves garlic" is named "cloves garlic", and
/// "1 large egg" is named "large egg". The raw text keeps everything else,
/// such as a container size.
IngredientLine withParsedParts(IngredientLine line, ParsedLine parsed) =>
    line.copyWith(
      quantity: parsed.quantity,
      quantityMax: parsed.quantityMax,
      unit: parsed.unit,
      name: _nameAsWritten(parsed),
      preparation: parsed.preparation,
    );

/// The span of [ParsedLine.text] from the first to the last of its size,
/// count word, and name, or the parsed name when they can't all be found.
String? _nameAsWritten(ParsedLine parsed) {
  final name = parsed.name;
  if (name == null || (parsed.size == null && parsed.countWord == null)) {
    return name;
  }
  final patterns = [
    if (parsed.size case final size?) RegExp.escape(size),
    if (parsed.countWord case final word?) '${RegExp.escape(word)}(?:e?s)?',
    RegExp.escape(name),
  ];
  final matches = [
    for (final pattern in patterns)
      RegExp('\\b$pattern\\b', caseSensitive: false).firstMatch(parsed.text),
  ];
  if (matches.contains(null)) return name;
  final found = matches.nonNulls;
  return parsed.text.substring(
    found.map((m) => m.start).reduce(min),
    found.map((m) => m.end).reduce(max),
  );
}
