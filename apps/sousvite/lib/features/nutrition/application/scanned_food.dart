import 'package:sousvite/app/services/nutrition_api.dart';

/// The ingredient line a [food] scanned from its package starts as: one
/// label serving in grams before its name, as in "32 g Creamy Peanut
/// Butter", or the name alone when the label gives no serving in grams.
///
/// Online foods carry at most one portion, the label serving.
String scannedLineText(OnlineFood food) {
  final name = food.food.name.trim();
  final grams = food.portions.firstOrNull?.gramWeight;
  if (grams == null || grams <= 0) return name;
  // One decimal at most, and none for whole grams: "32", "12.5".
  final amount = grams.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
  return '$amount g $name';
}
