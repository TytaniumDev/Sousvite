/// A blob id that would not be a safe file name.
final class InvalidBlobId(
  /// The id.
  final String id,
) implements Exception {
  /// Throws when [id] is not letters, digits, `-`, `_`, and `.`, or is
  /// longer than 128 characters.
  static void check(String id) {
    if (!_pattern.hasMatch(id)) throw InvalidBlobId(id);
  }

  static final _pattern = RegExp(r'^[A-Za-z0-9_\-][A-Za-z0-9_\-.]{0,127}$');

  @override
  String toString() => 'InvalidBlobId: $id';
}
