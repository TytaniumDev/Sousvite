/// Exact quantities, measuring units, and the math between them: scaling,
/// conversion, and rounding to amounts people can measure.
///
/// Pure Dart with no other workspace dependencies, so both `domain` and
/// `design_system` can use these types (ENGINEERING.md §4.2).
library;

export 'src/amount.dart';
export 'src/measurable_rounding.dart';
export 'src/quantity.dart';
export 'src/quantity_format.dart';
export 'src/scaling.dart';
export 'src/unit.dart';
export 'src/unit_aliases.dart';
export 'src/unit_conversion.dart';
export 'src/unit_system.dart';
