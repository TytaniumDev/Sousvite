import 'dart:math';

import 'package:domain/domain.dart';
import 'package:ingredient_parser/ingredient_parser.dart';

/// [line] with its amount, unit, count word, name, and preparation filled
/// in from [parsed], the parser's reading of its raw text
/// (ENGINEERING.md §12).
///
/// An ingredient line has no field for a size, so it stays in the name as
/// written: "1 large egg" is named "large egg". The raw text keeps
/// everything else, such as a container size.
IngredientLine withParsedParts(IngredientLine line, ParsedLine parsed) =>
    line.copyWith(
      quantity: parsed.quantity,
      quantityMax: parsed.quantityMax,
      unit: parsed.unit,
      countWord: parsed.countWord,
      name: _nameWithSize(parsed),
      preparation: parsed.preparation,
    );

/// The span of [ParsedLine.text] from the size to the end of the name, or
/// the parsed name when there is no size or they can't both be found.
String? _nameWithSize(ParsedLine parsed) {
  final ParsedLine(:name, :size, :text) = parsed;
  if (name == null || size == null) return name;
  final matches = [
    for (final part in [size, name])
      RegExp(
        '\\b${RegExp.escape(part)}\\b',
        caseSensitive: false,
      ).firstMatch(text),
  ];
  if (matches case [final a?, final b?]) {
    return text.substring(min(a.start, b.start), max(a.end, b.end));
  }
  return name;
}
