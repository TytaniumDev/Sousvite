import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/data/page_fetchers.dart';

/// The recipe page the import flow reads, as a recipe site serves it.
const recipePageUrl = 'https://example.com/tomato-soup';

const _tomatoSoup = r'''
<html><head><script type="application/ld+json">
{"@type": "Recipe", "name": "Tomato soup", "recipeYield": "4",
 "recipeIngredient": ["2 cups crushed tomatoes", "1 tbsp olive oil",
   "1 onion"],
 "recipeInstructions": "Soften the onion in the oil.\nAdd the tomatoes and simmer."}
</script></head></html>''';

/// Serves [recipePageUrl] with no network, so the flow doesn't depend on
/// a real site.
Future<FetchedPage> recipePageFetcher(Uri url) async {
  if (url.toString() != recipePageUrl) {
    throw ImportFailure(.unreachable, site: url.host);
  }
  return (url: url, html: _tomatoSoup);
}
