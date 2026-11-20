import 'package:sousvite/app/services/nutrition_api.dart';

/// The ingredient line a [food] scanned from its package starts as: one
/// label serving in grams before its name, as in "32 g Creamy Peanut
/// Butter", or the name alone when the label gives no serving in grams.
String scannedLineText(OnlineFood food) {
  final name = food.food.name.trim();
  return switch (labelServingGrams(food)) {
    final grams? => '${formatGrams(grams)} g $name',
    null => name,
  };
}

/// How many grams one label serving of [food] weighs, or null when the
/// label gives no serving in grams.
///
/// Online foods carry at most one portion, the label serving.
double? labelServingGrams(OnlineFood food) => switch (food.portions) {
  [final serving, ...] when serving.gramWeight > 0 => serving.gramWeight,
  _ => null,
};

/// [grams] with one decimal at most, and none for whole grams: "32",
/// "12.5".
String formatGrams(double grams) =>
    grams.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
