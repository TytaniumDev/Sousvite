import 'package:domain/domain.dart';

/// Reads a household serving such as "1 cup", "2 tbsp", "0.5 CUP", or
/// "1/4 cup" into an amount, or null for anything else ("1 bar", "about 8
/// chips"), which callers keep as a count.
Amount? parseServingText(String? text) {
  final match = _serving.firstMatch(text?.trim() ?? '');
  if (match == null) return null;
  final quantity = _quantity(match[1]!);
  final unit = unitFromAlias(match[2]!);
  if (quantity == null || quantity.isZero || unit == null) return null;
  return Amount(quantity, unit);
}

final _serving = RegExp(r'^(\d+(?:\.\d+)?|\d+/\d+)\s*([A-Za-z.]+)$');

Quantity? _quantity(String text) {
  if (text.contains('/')) {
    final [numerator, denominator] = text.split('/').map(int.parse).toList();
    return denominator == 0 ? null : Quantity(numerator, denominator);
  }
  final [whole, fraction] = [...text.split('.'), ''].take(2).toList();
  var denominator = 1;
  for (var i = 0; i < fraction.length; i++) {
    denominator *= 10;
  }
  return Quantity(int.parse('$whole$fraction'), denominator);
}
