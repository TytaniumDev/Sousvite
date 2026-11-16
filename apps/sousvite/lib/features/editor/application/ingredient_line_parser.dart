import 'package:ingredient_parser/ingredient_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ingredient_line_parser.g.dart';

/// Splits typed or pasted ingredient text into its parts (PRD 7.3).
typedef IngredientLineParser = ParsedLine Function(String text);

/// The parser the editor uses: `package:ingredient_parser`. A provider, so
/// tests can swap it.
@riverpod
IngredientLineParser ingredientLineParser(Ref ref) => parseIngredientLine;
