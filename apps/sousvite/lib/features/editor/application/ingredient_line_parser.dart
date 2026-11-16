import 'package:domain/domain.dart';
import 'package:ingredient_parser/ingredient_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ingredient_line_parser.g.dart';

/// Splits typed or pasted ingredient text into its parts (PRD 7.3).
typedef IngredientLineParser = ParsedLine Function(String text);

/// The parser the editor uses: `package:ingredient_parser`. A provider, so
/// tests can swap it.
@riverpod
IngredientLineParser ingredientLineParser(Ref ref) => parseIngredientLine;

/// How a parsed line fills an [IngredientLine].
extension ParsedLineParts on ParsedLine {
  /// The name to store. [IngredientLine] has no count word or size field
  /// yet, so they stay in the name ("3 cloves garlic" is 3 of "cloves
  /// garlic", "1 large egg" is 1 "large egg"). A line the parser finds no
  /// name in keeps its whole text, so nothing typed is lost.
  String? get storedName {
    final words = [
      ?size,
      if (countWord case final word?) _countWord(word),
      ?name,
    ];
    if (words.isNotEmpty) return words.join(' ');
    final whole = (heading ?? text).trim();
    return whole.isEmpty ? null : whole;
  }

  /// [word] as it reads with the amount: "clove" for 1, "cloves" for 3.
  String _countWord(String word) {
    if (quantity == Quantity.one && quantityMax == null) return word;
    final es = RegExp(r'(s|sh|ch|x|z)$').hasMatch(word);
    return es ? '${word}es' : '${word}s';
  }
}
