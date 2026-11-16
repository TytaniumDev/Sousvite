import 'package:html/dom.dart';
import 'package:recipe_import/src/text_cleanup.dart';
import 'package:recipe_import/src/url/recipe_page_data.dart';

/// A last try for pages without recipe markup: the `<h1>` as the name, and
/// the first list after a heading that says "Ingredients" and after one
/// that says "Instructions", "Directions", "Method", or "Steps".
///
/// Null unless it finds a name and both lists.
RecipePageData? readHeuristics(Document page) {
  final name = cleanText(page.querySelector('h1')?.text ?? '');
  final ingredients = _listAfter(page, _ingredientHeading);
  final steps = _listAfter(page, _stepHeading);
  if (name.isEmpty || ingredients.isEmpty || steps.isEmpty) return null;
  return RecipePageData(
    name: name,
    ingredients: [for (final text in ingredients) (section: null, text: text)],
    steps: [for (final text in steps) (section: null, text: text)],
  );
}

final _ingredientHeading = RegExp(r'^ingredients?\b', caseSensitive: false);
final _stepHeading = RegExp(
  r'^(instructions?|directions?|method|steps?|preparation)\b',
  caseSensitive: false,
);

/// The items of the first list that follows a heading matching [heading]
/// in document order.
List<String> _listAfter(Document page, RegExp heading) {
  final elements = page.querySelectorAll('h2, h3, h4, strong, ul, ol');
  var seen = false;
  for (final element in elements) {
    final tag = element.localName;
    if (tag == 'ul' || tag == 'ol') {
      if (!seen) continue;
      return [
        for (final item in element.children.where((e) => e.localName == 'li'))
          if (cleanText(item.text) case final text when text.isNotEmpty) text,
      ];
    }
    seen = seen || heading.hasMatch(cleanText(element.text));
  }
  return const [];
}
