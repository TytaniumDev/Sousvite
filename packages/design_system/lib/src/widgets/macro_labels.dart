import 'package:flutter/foundation.dart';

/// The words the nutrition widgets show, already localized by the app,
/// since `design_system` has no strings of its own.
@immutable
class const MacroLabels({
  /// "Calories".
  required final String calories,

  /// "Protein".
  required final String protein,

  /// "Carbs".
  required final String carbs,

  /// "Fat".
  required final String fat,

  /// The gram unit: "g".
  required final String grams,
}) {
  @override
  bool operator ==(Object other) =>
      other is MacroLabels &&
      other.calories == calories &&
      other.protein == protein &&
      other.carbs == carbs &&
      other.fat == fat &&
      other.grams == grams;

  @override
  int get hashCode => Object.hash(calories, protein, carbs, fat, grams);
}
