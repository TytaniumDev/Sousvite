import 'package:domain/domain.dart';
import 'package:ingredient_parser/ingredient_parser.dart';
import 'package:recipe_import/src/ingredient_parts.dart';
import 'package:recipe_import/src/text_cleanup.dart';

/// A line of an imported list, with the section it sits in, if any.
typedef SectionedText = ({String? section, String text});

/// An unsaved recipe with new ids from [newId], built from what an
/// importer read (ENGINEERING.md §14).
///
/// Each ingredient line is cleaned and goes through the ingredient parser.
/// A line that is a heading ("For the sauce:") names the section of the
/// lines after it that have none of their own. Sections are created in the
/// order they first appear.
RecipeSnapshot buildSnapshot({
  required String title,
  required List<SectionedText> ingredients,
  required List<SectionedText> steps,
  required String Function() newId,
  required DateTime now,
  String? yield,
  Duration? prepTime,
  Duration? cookTime,
  Duration? totalTime,
  String notes = '',
  String? sourceUrl,
  String? sourceName,
}) {
  final recipeId = RecipeId(newId());
  final ingredientSections = <String, IngredientSection>{};
  IngredientSectionId? ingredientSection(String? name) => name == null
      ? null
      : ingredientSections
            .putIfAbsent(
              name,
              () => IngredientSection(
                id: IngredientSectionId(newId()),
                recipeId: recipeId,
                name: name,
                sortKey: sortKeyAt(ingredientSections.length),
              ),
            )
            .id;
  final stepSections = <String, StepSection>{};
  StepSectionId? stepSection(String? name) => name == null
      ? null
      : stepSections
            .putIfAbsent(
              name,
              () => StepSection(
                id: StepSectionId(newId()),
                recipeId: recipeId,
                name: name,
                sortKey: sortKeyAt(stepSections.length),
              ),
            )
            .id;
  final parsedLines = _parsedIngredients(ingredients);
  return RecipeSnapshot(
    recipe: Recipe(
      id: recipeId,
      title: title,
      servings: servingsFromYield(yield) ?? Quantity.one,
      createdAt: now,
      updatedAt: now,
      prepTime: prepTime,
      cookTime: cookTime,
      totalTime: totalTime,
      notes: notes,
      sourceUrl: sourceUrl,
      sourceName: sourceName,
    ),
    ingredientLines: [
      for (final (index, (:section, :parsed)) in parsedLines.indexed)
        withParsedParts(
          IngredientLine(
            id: IngredientLineId(newId()),
            recipeId: recipeId,
            rawText: parsed.text,
            sortKey: sortKeyAt(index),
            sectionId: ingredientSection(section),
          ),
          parsed,
        ),
    ],
    ingredientSections: ingredientSections.values.toList(),
    steps: [
      for (final (index, (:section, :text)) in steps.indexed)
        RecipeStep(
          id: RecipeStepId(newId()),
          recipeId: recipeId,
          text: text,
          sortKey: sortKeyAt(index),
          sectionId: stepSection(section),
        ),
    ],
    stepSections: stepSections.values.toList(),
  );
}

/// Each ingredient line, cleaned and parsed, with its section. A heading
/// line names the section of the lines after it that have none.
List<({String? section, ParsedLine parsed})> _parsedIngredients(
  List<SectionedText> lines,
) {
  final parsedLines = <({String? section, ParsedLine parsed})>[];
  String? heading;
  for (final (:section, :text) in lines) {
    final parsed = parseIngredientLine(cleanIngredient(text));
    if (parsed.heading case final title?) {
      heading = title.substring(0, 1).toUpperCase() + title.substring(1);
    } else {
      parsedLines.add((section: section ?? heading, parsed: parsed));
    }
  }
  return parsedLines;
}

/// The number of servings in a yield such as "4 servings", "Serves 4-6",
/// or "12": its first whole number. Null when it has none, or when it
/// counts something else ("1 loaf" still reads as 1).
Quantity? servingsFromYield(String? yield) {
  final match = RegExp(r'\d+').firstMatch(yield ?? '');
  final count = int.tryParse(match?[0] ?? '');
  return count == null || count <= 0 ? null : Quantity(count);
}

/// A sort key for the [index]th item of a new recipe: keys compare as
/// strings, and leave room for a fractional index between neighbours.
SortKey sortKeyAt(int index) => SortKey('a${index.toString().padLeft(6, '0')}');
