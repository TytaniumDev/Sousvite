import 'package:clock/clock.dart';
import 'package:domain/domain.dart';
import 'package:recipe_import/recipe_import.dart';
import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/application/recipe_importers.dart';
import 'package:sousvite/features/import/data/page_fetchers.dart';

/// Imports a recipe by fetching its page with [_fetch] and reading it with
/// `recipe_import`, and saves its photo (ENGINEERING.md §14).
class const PageUrlImporter(
  final PageFetcher _fetch, {

  /// Makes the ids of the new recipe and its parts.
  required final String Function() newId,

  /// Saves the photo at an address on this device, and returns the
  /// recipe's `photoRef` for it (`RecipePhotos.importFrom`).
  required final Future<String?> Function(String? url) importPhoto,
}) implements UrlImporter {
  @override
  Future<RecipeSnapshot> importUrl(Uri url) async {
    final page = await _fetch(url);
    final RecipePage read;
    try {
      read = readRecipePage(
        page.html,
        url: page.url,
        newId: newId,
        now: clock.now(),
      );
    } on RecipePageFailure {
      throw ImportFailure(.noRecipe, site: url.host);
    }
    final snapshot = read.snapshot;
    final photoRef = await importPhoto(read.imageUrl);
    if (photoRef == null) return snapshot;
    return snapshot.copyWith(
      recipe: snapshot.recipe.copyWith(photoRef: photoRef),
    );
  }
}
