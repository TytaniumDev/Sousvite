import 'package:domain/domain.dart';

/// Teaspoons of jarred minced garlic that stand in for one clove, as jar
/// labels say ("substitute ½ tsp for 1 clove of fresh garlic").
final Quantity jarredGarlicTeaspoonsPerClove = Quantity(1, 2);

final _garlic = RegExp(r'\bgarlic\b', caseSensitive: false);
final _clove = RegExp(r'\bcloves?\b', caseSensitive: false);

/// Whether an amount counts garlic cloves, so it can be shown as jarred
/// garlic: "3 cloves garlic" (count word "clove", name "garlic") or "4
/// garlic cloves" (no count word, name "garlic cloves").
///
/// An amount with a [unit] ("1 tsp minced garlic") or another count word
/// ("1 head garlic") is not.
bool isGarlicCloves({
  required String name,
  required Unit? unit,
  required String? countWord,
}) {
  if (unit != null || !_garlic.hasMatch(name)) return false;
  return countWord == null ? _clove.hasMatch(name) : _clove.hasMatch(countWord);
}

/// Extensions for showing garlic cloves as jarred garlic.
extension JarredGarlic on Amount {
  /// This many cloves as teaspoons of jarred garlic.
  Amount get asJarredGarlic =>
      Amount(quantity * jarredGarlicTeaspoonsPerClove, Unit.teaspoon);
}
