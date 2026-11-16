import 'package:domain/domain.dart';
import 'package:meta/meta.dart';

/// An amount in a measuring unit that a line gives besides its main
/// amount: a container's size ("15 oz" in "1 (15 oz) can") or the same
/// amount in another unit ("240 ml" in "1 cup (240 ml) milk").
@immutable
final class const ParsedAmount({
  /// How much, or the bottom of a range.
  required final Quantity quantity,

  /// The unit.
  required final Unit unit,

  /// The top of a range ("13- to 14-ounce"). Null when not a range.
  final Quantity? quantityMax,
}) {
  @override
  bool operator ==(Object other) =>
      other is ParsedAmount &&
      other.quantity == quantity &&
      other.quantityMax == quantityMax &&
      other.unit == unit;

  @override
  int get hashCode => Object.hash(quantity, quantityMax, unit);

  /// A debug form such as `15 ounce` or `13-14 ounce`.
  @override
  String toString() =>
      '$quantity${quantityMax == null ? '' : '-$quantityMax'} ${unit.name}';
}
