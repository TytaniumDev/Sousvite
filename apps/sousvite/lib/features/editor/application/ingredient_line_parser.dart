import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ingredient_line_parser.g.dart';

/// An ingredient line split into its parts: "1 ½ cups oats, toasted".
typedef ParsedIngredient = ({
  Quantity? quantity,
  Quantity? quantityMax,
  Unit? unit,
  String? name,
  String? preparation,
});

/// Splits typed or pasted ingredient text into its parts (PRD 7.3).
typedef IngredientLineParser = ParsedIngredient Function(String text);

/// The parser the editor uses.
///
/// Until the ingredient parser (PAR-1) lands, the whole line is the name,
/// so nothing is lost. PAR-1 replaces this body with
/// `package:ingredient_parser`; nothing else changes.
@riverpod
IngredientLineParser ingredientLineParser(Ref ref) =>
    (text) => (
      quantity: null,
      quantityMax: null,
      unit: null,
      name: text.trim().isEmpty ? null : text.trim(),
      preparation: null,
    );
