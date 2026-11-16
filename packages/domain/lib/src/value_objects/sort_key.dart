/// A fractional index used to order sections, steps, ingredients, and
/// grocery items (ENGINEERING.md §7).
///
/// Keys compare as plain strings. Moving one item writes one new key
/// between its neighbours with [SortKey.between], so a reorder changes one
/// row and merges cleanly during sync.
extension type const SortKey(String value) implements Comparable<String> {
  /// A key that sorts after [before] and before [after]. Null [before]
  /// means the start of the list and null [after] the end, so
  /// `SortKey.between(last, null)` appends.
  ///
  /// Keys made here never end in `0`, so there is always room between
  /// two of them. [before] must sort before [after].
  factory between(SortKey? before, SortKey? after) {
    final low = before?.value ?? '';
    final high = after?.value;
    if (high != null && low.compareTo(high) >= 0) {
      throw ArgumentError('$before must sort before $after');
    }
    return SortKey(_midpoint(low, high));
  }

  /// The digits keys are written in, in string order.
  static const _digits =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  /// [count] keys in order, for a new list.
  static List<SortKey> sequence(int count) {
    final keys = <SortKey>[];
    for (var i = 0; i < count; i++) {
      keys.add(SortKey.between(keys.lastOrNull, null));
    }
    return keys;
  }

  /// A string between [low] and [high] (null meaning past the end), from
  /// the fractional indexing method used by Figma and Linear.
  static String _midpoint(String low, String? high) {
    if (high != null) {
      // Copy the prefix the two share, then split the rest.
      var shared = 0;
      while (shared < high.length &&
          (shared < low.length ? low[shared] : _digits[0]) == high[shared]) {
        shared++;
      }
      if (shared > 0) {
        return high.substring(0, shared) +
            _midpoint(
              shared < low.length ? low.substring(shared) : '',
              high.substring(shared),
            );
      }
    }
    final lowDigit = low.isEmpty ? 0 : _digits.indexOf(low[0]);
    final highDigit = high == null ? _digits.length : _digits.indexOf(high[0]);
    if (highDigit - lowDigit > 1) {
      return _digits[(lowDigit + highDigit) ~/ 2];
    }
    // The first digits are adjacent: keep the high one if it has more
    // digits after it, or else go one digit deeper after the low one.
    if (high != null && high.length > 1) return high.substring(0, 1);
    return _digits[lowDigit] +
        _midpoint(low.isEmpty ? '' : low.substring(1), null);
  }
}
