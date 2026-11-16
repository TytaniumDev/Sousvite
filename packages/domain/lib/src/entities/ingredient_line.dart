import 'package:domain/src/value_objects/ids.dart';
import 'package:domain/src/value_objects/sort_key.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:units/units.dart';

part 'ingredient_line.freezed.dart';

/// One ingredient line: the text the user typed, plus the parts parsed from
/// it. Any parsed part can be corrected by the user (PRD 7.3).
///
/// `"1 ½ cups rolled oats, chopped"` has [quantity] 3/2, [unit] cup,
/// [name] "rolled oats" and [preparation] "chopped".
@freezed
abstract class IngredientLine with _$IngredientLine {
  const factory({
    required IngredientLineId id,
    required RecipeId recipeId,
    required String rawText,
    required SortKey sortKey,
    IngredientSectionId? sectionId,
    Quantity? quantity,

    /// The upper end of a range such as "2–3". Null when not a range.
    Quantity? quantityMax,
    Unit? unit,

    /// A count word used as the unit when [unit] has none, singular and
    /// lowercase: "clove" in "3 cloves garlic", "can" in "1 can beans".
    /// Kept as text so any word works (ENGINEERING.md §12). Null when
    /// [unit] is set or the line has neither.
    String? countWord,
    String? name,
    String? preparation,
  }) = _IngredientLine;
}
