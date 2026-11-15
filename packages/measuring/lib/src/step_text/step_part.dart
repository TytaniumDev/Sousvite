import 'package:domain/domain.dart';
import 'package:meta/meta.dart';

/// One part of a step after smart step text: words as written, or an
/// ingredient mention with its amount placed inline.
@immutable
sealed class const StepPart();

/// Words from the step, unchanged.
final class const StepWords(
  /// The words, including any spaces around them.
  final String text,
) extends StepPart {
  @override
  bool operator ==(Object other) => other is StepWords && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => text;
}

/// A mention of an ingredient, shown as its amount and name: "add the
/// garlic" becomes "add **6** garlic cloves".
///
/// The editor marks these so the user can see and undo them; undoing shows
/// [original] again.
final class const StepMention({
  /// The ingredient line this mention refers to.
  required final IngredientLineId lineId,

  /// The step text this mention replaces, such as "the garlic".
  required final String original,

  /// The line's amount, scaled. The app rounds and converts it like the
  /// ingredient list does.
  required final Amount amount,

  /// The ingredient's name to show after the amount, as written on the
  /// line, such as "garlic cloves".
  required final String name,

  /// The top of a range ("2–3 cloves"), scaled. Null when not a range.
  final Quantity? amountMax,
}) extends StepPart {
  @override
  bool operator ==(Object other) =>
      other is StepMention &&
      other.lineId == lineId &&
      other.original == original &&
      other.amount == amount &&
      other.amountMax == amountMax &&
      other.name == name;

  @override
  int get hashCode => Object.hash(lineId, original, amount, amountMax, name);

  /// A debug form such as `[3/2 cup: rolled oats]`.
  @override
  String toString() {
    final max = amountMax == null ? '' : '-$amountMax';
    final unit = amount.unit == null ? '' : ' ${amount.unit!.name}';
    return '[${amount.quantity}$max$unit: $name]';
  }
}
