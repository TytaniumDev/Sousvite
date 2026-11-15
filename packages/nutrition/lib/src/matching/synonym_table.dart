import 'package:nutrition/src/matching/food_text.dart';

/// Rewrites an ingredient name before matching, so cooks' words line up
/// with USDA's.
///
/// Write each replacement with its main word last ("green onion", not
/// "onion, green"): the matcher treats the last word as the main one.
final class SynonymTable({
  /// Phrases rewritten wherever they appear: "scallion" becomes
  /// "green onion" and "unsalted" becomes "without salt". A phrase that
  /// maps to an empty string is removed, which drops preparation words
  /// such as "chopped".
  Map<String, String> phrases = const {},

  /// Whole names rewritten after [phrases], to pick the usual form of a
  /// food: "milk" alone becomes "whole milk", while "coconut milk" stays.
  Map<String, String> defaults = const {},
}) {
  /// Phrase tokens to replacement tokens, longest phrase first, so
  /// "kosher salt" wins over "salt".
  final List<(List<String>, List<String>)> _phrases = [
    for (final MapEntry(:key, :value) in phrases.entries)
      (foodTokens(key), foodTokens(value)),
  ]..sort((a, b) => b.$1.length.compareTo(a.$1.length));

  final Map<String, List<String>> _defaults = {
    for (final MapEntry(:key, :value) in defaults.entries)
      foodTokens(key).join(' '): foodTokens(value),
  };

  /// [tokens] with every phrase replaced, scanning left to right, and then
  /// the whole result replaced by its default, if it has one.
  List<String> apply(List<String> tokens) {
    final result = <String>[];
    var index = 0;
    while (index < tokens.length) {
      final rule = _phrases.where((r) => _startsWith(tokens, index, r.$1));
      if (rule.isEmpty) {
        result.add(tokens[index]);
        index++;
      } else {
        result.addAll(rule.first.$2);
        index += rule.first.$1.length;
      }
    }
    return _defaults[result.join(' ')] ?? result;
  }

  static bool _startsWith(List<String> tokens, int index, List<String> phrase) {
    if (phrase.isEmpty || index + phrase.length > tokens.length) return false;
    for (var i = 0; i < phrase.length; i++) {
      if (tokens[index + i] != phrase[i]) return false;
    }
    return true;
  }
}
