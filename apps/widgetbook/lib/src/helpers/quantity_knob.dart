import 'package:units/units.dart';
import 'package:widgetbook/widgetbook.dart';

/// Amounts a recipe commonly uses, from a pinch to a dozen.
final List<Quantity> sampleQuantities = [
  Quantity(1, 8),
  Quantity(1, 4),
  Quantity(1, 3),
  Quantity(1, 2),
  Quantity(2, 3),
  Quantity(3, 4),
  Quantity.one,
  Quantity(3, 2),
  Quantity(9, 4),
  Quantity(4),
  Quantity(12),
  Quantity(5, 16),
];

/// A dropdown knob for a [Quantity], labeled the way the app formats it.
extension QuantityKnobs on KnobsBuilder {
  /// Picks one of [sampleQuantities], starting at [initialValue].
  Quantity quantity({required String label, Quantity? initialValue}) =>
      object.dropdown(
        label: label,
        options: sampleQuantities,
        initialOption: initialValue,
        labelBuilder: (quantity) => quantity.format(),
      );
}
