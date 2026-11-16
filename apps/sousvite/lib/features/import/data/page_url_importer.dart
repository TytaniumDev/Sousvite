import 'package:clock/clock.dart';
import 'package:domain/domain.dart';
import 'package:recipe_import/recipe_import.dart';
import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/application/recipe_importers.dart';
import 'package:sousvite/features/import/data/page_fetchers.dart';

/// Imports a recipe by fetching its page with [_fetch] and reading it with
/// `recipe_import` (ENGINEERING.md §14).
class const PageUrlImporter(
  final PageFetcher _fetch, {

  /// Makes the ids of the new recipe and its parts.
  required final String Function() newId,
}) implements UrlImporter {
  @override
  Future<RecipeSnapshot> importUrl(Uri url) async {
    final page = await _fetch(url);
    try {
      return readRecipePage(
        page.html,
        url: page.url,
        newId: newId,
        now: clock.now(),
      ).snapshot;
    } on RecipePageFailure {
      throw ImportFailure(.noRecipe, site: url.host);
    }
  }
}
