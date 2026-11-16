import 'package:domain/domain.dart';
import 'package:ingredient_parser/src/parsed_amount.dart';
import 'package:meta/meta.dart';

/// An ingredient line split into its parts (ENGINEERING.md §12), such as
/// `"1 ½ cups rolled oats, chopped"` → quantity 3/2, unit cup, name
/// "rolled oats", preparation "chopped".
///
/// Every part is optional: "Salt to taste" has only a name and a
/// preparation, and "For the sauce:" is only a [heading].
@immutable
final class const ParsedLine({
  /// The line as written.
  required final String text,

  /// The title of a section heading, such as "sauce" for "For the
  /// sauce:". A heading has no other parts.
  final String? heading,

  /// How much, or the bottom of a range ("2" in "2–3 cloves").
  final Quantity? quantity,

  /// The top of a range. Null when not a range.
  final Quantity? quantityMax,

  /// The measuring unit, when the line has one the app knows.
  final Unit? unit,

  /// A count word used as the unit, singular and lowercase, such as
  /// "clove" in "3 cloves garlic" or "can" in "1 (15 oz) can beans". Null
  /// when [unit] is set or the line has neither.
  final String? countWord,

  /// The size of one container ("15 oz" in "1 (15 oz) can").
  final ParsedAmount? package,

  /// The same amount in another unit ("240 ml" in "1 cup (240 ml)").
  final ParsedAmount? alternate,

  /// A size that describes each item: "large", "2-inch".
  final String? size,

  /// The ingredient, as written in the line.
  final String? name,

  /// Everything else about the ingredient: preparation, notes, "to
  /// taste", in the order they appear, joined with ", ".
  final String? preparation,
}) {
  /// Whether this line is a section heading.
  bool get isHeading => heading != null;

  @override
  bool operator ==(Object other) =>
      other is ParsedLine &&
      other.text == text &&
      other.heading == heading &&
      other.quantity == quantity &&
      other.quantityMax == quantityMax &&
      other.unit == unit &&
      other.countWord == countWord &&
      other.package == package &&
      other.alternate == alternate &&
      other.size == size &&
      other.name == name &&
      other.preparation == preparation;

  @override
  int get hashCode => Object.hash(
    text,
    heading,
    quantity,
    quantityMax,
    unit,
    countWord,
    package,
    alternate,
    size,
    name,
    preparation,
  );

  @override
  String toString() => [
    if (heading != null) 'heading: $heading',
    if (quantity != null) 'quantity: $quantity',
    if (quantityMax != null) 'quantityMax: $quantityMax',
    if (unit != null) 'unit: ${unit!.name}',
    if (countWord != null) 'countWord: $countWord',
    if (package != null) 'package: $package',
    if (alternate != null) 'alternate: $alternate',
    if (size != null) 'size: $size',
    if (name != null) 'name: $name',
    if (preparation != null) 'preparation: $preparation',
  ].join(', ');
}
