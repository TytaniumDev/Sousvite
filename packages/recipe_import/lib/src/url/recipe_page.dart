import 'package:domain/domain.dart';
import 'package:html/parser.dart' as html;
import 'package:ingredient_parser/ingredient_parser.dart';
import 'package:recipe_import/src/ingredient_parts.dart';
import 'package:recipe_import/src/url/heuristics.dart';
import 'package:recipe_import/src/url/json_ld.dart';
import 'package:recipe_import/src/url/microdata.dart';
import 'package:recipe_import/src/url/recipe_page_data.dart';
import 'package:recipe_import/src/url/text_cleanup.dart';

/// Why a page couldn't be imported, so the app can report failures by
/// site (PRD §10).
enum RecipePageFailureReason() {
  /// The page has no recipe markup, and the heuristics found no recipe.
  noRecipe,
}

/// A page that couldn't be read as a recipe.
final class const RecipePageFailure(
  /// Why.
  final RecipePageFailureReason reason,

  /// The page's address.
  final Uri url,
) implements Exception {
  @override
  String toString() => 'RecipePageFailure(${reason.name}, $url)';
}

/// How the recipe was found on the page, for the fixture report.
enum RecipePageSource() {
  jsonLd,
  microdata,
  heuristics,
}

/// A recipe read from a page: the unsaved draft, how it was found, and its
/// photo's address, for MEDIA-1 to download.
typedef RecipePage = ({
  RecipeSnapshot snapshot,
  RecipePageSource source,
  String? imageUrl,
});

/// The recipe on the page at [url] whose HTML is [page], as an unsaved
/// draft with new ids from [newId] (ENGINEERING.md §14).
///
/// Reads schema.org JSON-LD first, then microdata, then heuristics. Each
/// ingredient line goes through the ingredient parser, and a line that is a
/// heading ("For the sauce:") starts a section. Throws [RecipePageFailure]
/// when the page has no recipe.
RecipePage readRecipePage(
  String page, {
  required Uri url,
  required String Function() newId,
  required DateTime now,
}) {
  final document = html.parse(page);
  final (data, source) = switch ((
    readJsonLd(document),
    readMicrodata(document),
  )) {
    (final data?, _) => (data, RecipePageSource.jsonLd),
    (null, final data?) => (data, RecipePageSource.microdata),
    _ => switch (readHeuristics(document)) {
      final data? => (data, RecipePageSource.heuristics),
      null => throw RecipePageFailure(.noRecipe, url),
    },
  };
  final siteName = document
      .querySelector('meta[property="og:site_name"]')
      ?.attributes['content'];
  return (
    snapshot: _snapshot(
      data,
      url: url,
      siteName: siteName == null ? null : cleanText(siteName),
      newId: newId,
      now: now,
    ),
    source: source,
    imageUrl: data.imageUrl == null
        ? null
        : url.resolve(data.imageUrl!).toString(),
  );
}

RecipeSnapshot _snapshot(
  RecipePageData data, {
  required Uri url,
  required String? siteName,
  required String Function() newId,
  required DateTime now,
}) {
  final recipeId = RecipeId(newId());
  final ingredientSections = <String, IngredientSection>{};
  final stepSections = <String, StepSection>{};
  final ingredients = _parsedIngredients(data.ingredients);
  return RecipeSnapshot(
    recipe: Recipe(
      id: recipeId,
      title: data.name,
      servings: servingsFromYield(data.yield) ?? Quantity.one,
      createdAt: now,
      updatedAt: now,
      prepTime: parseIsoDuration(data.prepTime),
      cookTime: parseIsoDuration(data.cookTime),
      totalTime: parseIsoDuration(data.totalTime),
      sourceUrl: url.toString(),
      sourceName: siteName == null || siteName.isEmpty
          ? url.host.replaceFirst(RegExp(r'^www\.'), '')
          : siteName,
    ),
    ingredientLines: [
      for (final (index, (:section, :parsed)) in ingredients.indexed)
        withParsedParts(
          IngredientLine(
            id: IngredientLineId(newId()),
            recipeId: recipeId,
            rawText: parsed.text,
            sortKey: sortKeyAt(index),
            sectionId: section == null
                ? null
                : ingredientSections
                      .putIfAbsent(
                        section,
                        () => IngredientSection(
                          id: IngredientSectionId(newId()),
                          recipeId: recipeId,
                          name: section,
                          sortKey: sortKeyAt(ingredientSections.length),
                        ),
                      )
                      .id,
          ),
          parsed,
        ),
    ],
    ingredientSections: ingredientSections.values.toList(),
    steps: [
      for (final (index, (:section, :text)) in data.steps.indexed)
        RecipeStep(
          id: RecipeStepId(newId()),
          recipeId: recipeId,
          text: text,
          sortKey: sortKeyAt(index),
          sectionId: section == null
              ? null
              : stepSections
                    .putIfAbsent(
                      section,
                      () => StepSection(
                        id: StepSectionId(newId()),
                        recipeId: recipeId,
                        name: section,
                        sortKey: sortKeyAt(stepSections.length),
                      ),
                    )
                    .id,
        ),
    ],
    stepSections: stepSections.values.toList(),
  );
}

/// Each ingredient line, cleaned and parsed, with its section. A heading
/// line ("For the sauce:") names the section of the lines after it that
/// the page's markup doesn't put in one.
List<({String? section, ParsedLine parsed})> _parsedIngredients(
  List<({String? section, String text})> lines,
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
