import 'package:html/dom.dart';
import 'package:recipe_import/src/url/recipe_page_data.dart';
import 'package:recipe_import/src/url/text_cleanup.dart';

/// The first schema.org `Recipe` marked up with microdata
/// (`itemtype="https://schema.org/Recipe"`), or null.
RecipePageData? readMicrodata(Document page) {
  final recipe = page
      .querySelectorAll('[itemscope][itemtype]')
      .where((element) => element.attributes['itemtype']!.endsWith('/Recipe'))
      .firstOrNull;
  if (recipe == null) return null;
  final name = _first(recipe, 'name');
  if (name == null) return null;
  return RecipePageData(
    name: name,
    ingredients: [
      for (final text in _all(recipe, 'recipeIngredient', 'ingredients'))
        (section: null, text: text),
    ],
    steps: [
      for (final element in _elements(recipe, 'recipeInstructions'))
        for (final text in _stepTexts(element)) (section: null, text: text),
    ],
    yield: _first(recipe, 'recipeYield'),
    prepTime: _first(recipe, 'prepTime'),
    cookTime: _first(recipe, 'cookTime'),
    totalTime: _first(recipe, 'totalTime'),
    imageUrl: _first(recipe, 'image'),
  );
}

/// Elements with [prop] that belong to [scope], not to a nested item.
Iterable<Element> _elements(Element scope, String prop) => scope
    .querySelectorAll('[itemprop~="$prop"]')
    .where((element) => _owner(element) == scope);

Element? _owner(Element element) {
  for (var parent = element.parent; parent != null; parent = parent.parent) {
    if (parent.attributes.containsKey('itemscope')) return parent;
  }
  return null;
}

/// An element's value: `content`, `datetime`, `src`, or `href`, else its
/// text.
String? _value(Element element) {
  final attributes = element.attributes;
  final value =
      attributes['content'] ??
      attributes['datetime'] ??
      attributes['src'] ??
      attributes['href'] ??
      element.text;
  final text = cleanText(value);
  return text.isEmpty ? null : text;
}

String? _first(Element scope, String prop) =>
    _elements(scope, prop).map(_value).nonNulls.firstOrNull;

List<String> _all(Element scope, String prop, String fallback) {
  final values = _elements(scope, prop).map(_value).nonNulls.toList();
  return values.isNotEmpty
      ? values
      : _elements(scope, fallback).map(_value).nonNulls.toList();
}

/// Instructions are one element per step, or one element holding a list.
List<String> _stepTexts(Element element) {
  final items = element.querySelectorAll('li');
  if (items.isEmpty) return [?_value(element)];
  return items
      .map((item) => cleanText(item.text))
      .where((t) => t.isNotEmpty)
      .toList();
}
