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
  /// The name to store. [IngredientLine] has no size field, so a size stays
  /// in the name ("1 large egg" is 1 "large egg"). A line the parser finds
  /// no name in keeps its whole text, so nothing typed is lost.
  String? get storedName {
    if (name case final name?) {
      return size == null ? name : '$size $name';
    }
    final whole = (heading ?? text).trim();
    return whole.isEmpty ? null : whole;
  }
}
