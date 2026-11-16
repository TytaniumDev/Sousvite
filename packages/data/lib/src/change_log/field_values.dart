import 'package:domain/domain.dart';

// How entity fields are written as JSON values in the change log, and read
// back. Every repository uses these, so a field means the same thing on
// every device.

/// A [Quantity] as `{'n': numerator, 'd': denominator}`.
Object? encodeQuantity(Quantity? quantity) => quantity == null
    ? null
    : {'n': quantity.numerator, 'd': quantity.denominator};

/// Reads a value written by [encodeQuantity].
Quantity? decodeQuantity(Object? value) => switch (value) {
  {'n': final int numerator, 'd': final int denominator} => Quantity(
    numerator,
    denominator,
  ),
  _ => null,
};

/// A [Duration] as whole seconds.
int? encodeDuration(Duration? duration) => duration?.inSeconds;

/// Reads a value written by [encodeDuration].
Duration? decodeDuration(Object? value) =>
    value is int ? Duration(seconds: value) : null;

/// A [DateTime] as UTC ISO 8601 text.
String? encodeDateTime(DateTime? dateTime) =>
    dateTime?.toUtc().toIso8601String();

/// Reads a value written by [encodeDateTime].
DateTime? decodeDateTime(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

/// An enum value as its name.
String? encodeEnum(Enum? value) => value?.name;

/// Reads a value written by [encodeEnum], or null for a name not in
/// [values], such as one from a newer app version.
T? decodeEnum<T extends Enum>(List<T> values, Object? value) {
  for (final candidate in values) {
    if (candidate.name == value) return candidate;
  }
  return null;
}
