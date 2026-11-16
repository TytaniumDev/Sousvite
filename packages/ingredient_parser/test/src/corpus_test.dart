import 'dart:convert';
import 'dart:io';

import 'package:ingredient_parser/ingredient_parser.dart';
import 'package:test/test.dart';

/// The share of corpus lines the parser must get fully right. Raise it as
/// the parser improves (BUILD_PLAN.md PAR-1).
const _minimumPassRate = 0.98;

final _punctuation = RegExp(r'[^\w\s]', unicode: true);
final _spaces = RegExp(r'\s+');

/// A text field as the corpus README compares it: lowercased, without
/// punctuation, with single spaces. Empty counts as absent.
String? _text(Object? value) {
  if (value == null) return null;
  final text = (value as String)
      .toLowerCase()
      .replaceAll(_punctuation, '')
      .replaceAll(_spaces, ' ')
      .trim();
  return text.isEmpty ? null : text;
}

Map<String, Object?>? _amount(ParsedAmount? amount) => amount == null
    ? null
    : {
        'quantity': '${amount.quantity}',
        if (amount.quantityMax != null) 'quantityMax': '${amount.quantityMax}',
        'unit': amount.unit.name,
      };

/// [line] in the corpus format, with text fields normalized.
Map<String, Object?> _fields(ParsedLine line) => {
  'heading': _text(line.heading),
  'quantity': line.quantity?.toString(),
  'quantityMax': line.quantityMax?.toString(),
  'unit': line.unit?.name ?? line.countWord,
  'package': _amount(line.package),
  'alternate': _amount(line.alternate),
  'size': _text(line.size),
  'name': _text(line.name),
  'preparation': _text(line.preparation),
};

Map<String, Object?> _expected(Map<String, Object?> row) => {
  'heading': _text(row['heading']),
  'quantity': row['quantity'],
  'quantityMax': row['quantityMax'],
  'unit': row['unit'],
  'package': row['package'],
  'alternate': row['alternate'],
  'size': _text(row['size']),
  'name': _text(row['name']),
  'preparation': _text(row['preparation']),
};

List<Map<String, Object?>> _rows(String file) => [
  for (final line in File('test/fixtures/$file').readAsLinesSync())
    if (line.trim().isNotEmpty) jsonDecode(line) as Map<String, Object?>,
];

void main() {
  for (final file in ['real_lines.jsonl', 'cases.jsonl']) {
    test('parses at least ${_minimumPassRate * 100}% of $file', () {
      final rows = _rows(file);
      final failures = <String>[];
      for (final row in rows) {
        final text = row['text']! as String;
        final actual = _fields(parseIngredientLine(text));
        final expected = _expected(row);
        final wrong = [
          for (final key in expected.keys)
            if (!_same(actual[key], expected[key])) key,
        ];
        if (wrong.isNotEmpty) {
          failures.add(
            [
              text,
              for (final key in wrong)
                '  $key: ${actual[key]} (want ${expected[key]})',
            ].join('\n'),
          );
        }
      }
      final rate = 1 - failures.length / rows.length;
      // The pass rate is part of the CI log (BUILD_PLAN.md PAR-1).
      // ignore: avoid_print, reporting the corpus pass rate is the point.
      print(
        '$file: ${rows.length - failures.length}/${rows.length} '
        '(${(rate * 100).toStringAsFixed(1)}%)\n${failures.join('\n')}',
      );
      expect(rate, greaterThanOrEqualTo(_minimumPassRate));
    });
  }
}

bool _same(Object? a, Object? b) => jsonEncode(a) == jsonEncode(b);
