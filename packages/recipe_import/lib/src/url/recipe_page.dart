import 'package:domain/domain.dart';
import 'package:html/parser.dart' as html;
import 'package:recipe_import/src/snapshot_builder.dart';
import 'package:recipe_import/src/text_cleanup.dart';
import 'package:recipe_import/src/url/heuristics.dart';
import 'package:recipe_import/src/url/json_ld.dart';
import 'package:recipe_import/src/url/microdata.dart';

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
    snapshot: buildSnapshot(
      title: data.name,
      ingredients: data.ingredients,
      steps: data.steps,
      newId: newId,
      now: now,
      yield: data.yield,
      prepTime: parseIsoDuration(data.prepTime),
      cookTime: parseIsoDuration(data.cookTime),
      totalTime: parseIsoDuration(data.totalTime),
      sourceUrl: url.toString(),
      sourceName: switch (siteName == null ? '' : cleanText(siteName)) {
        '' => url.host.replaceFirst(RegExp(r'^www\.'), ''),
        final name => name,
      },
    ),
    source: source,
    imageUrl: data.imageUrl == null
        ? null
        : url.resolve(data.imageUrl!).toString(),
  );
}
