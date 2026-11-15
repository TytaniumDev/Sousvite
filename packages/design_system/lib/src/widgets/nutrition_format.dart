/// How a nutrition value is rounded for display (DESIGN_SYSTEM.md §10.5).
enum NutrientPrecision() {
  /// Whole numbers: calories and milligrams.
  whole,

  /// Grams: whole numbers at 10 and above, one decimal below 10.
  grams;

  /// [value] rounded and written for display: `12`, `4.5`, `0`.
  String format(double value) {
    if (this == grams && value.abs() < 10) {
      final text = value.toStringAsFixed(1);
      // "4.0" reads as noise; whole numbers drop the decimal.
      return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
    }
    return value.round().toString();
  }
}
