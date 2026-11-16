import 'dart:convert';

import 'package:html/dom.dart';
import 'package:recipe_import/src/text_cleanup.dart';
import 'package:recipe_import/src/url/recipe_page_data.dart';

/// The first schema.org `Recipe` in the page's JSON-LD scripts, or null.
///
/// Handles a recipe at the top level, in an array, in `@graph`, or as the
/// `mainEntity` of a page, and `@type` given as a string or a list.
RecipePageData? readJsonLd(Document page) {
  for (final script in page.querySelectorAll(
    'script[type="application/ld+json"]',
  )) {
    final Object? json;
    try {
      json = jsonDecode(script.text);
    } on FormatException {
      continue;
    }
    final recipe = _findRecipe(json);
    if (recipe != null) return _read(recipe);
  }
  return null;
}

Map<String, Object?>? _findRecipe(Object? json) => switch (json) {
  final List<Object?> items => items.map(_findRecipe).nonNulls.firstOrNull,
  final Map<String, Object?> node when _isRecipe(node['@type']) => node,
  final Map<String, Object?> node =>
    _findRecipe(node['@graph']) ?? _findRecipe(node['mainEntity']),
  _ => null,
};

bool _isRecipe(Object? type) => switch (type) {
  final String type => type == 'Recipe' || type.endsWith('/Recipe'),
  final List<Object?> types => types.any(_isRecipe),
  _ => false,
};

RecipePageData? _read(Map<String, Object?> recipe) {
  final name = _string(recipe['name']);
  if (name == null) return null;
  return RecipePageData(
    name: name,
    ingredients: [
      for (final text in _strings(
        recipe['recipeIngredient'] ?? recipe['ingredients'],
      ))
        (section: null, text: text),
    ],
    steps: _steps(recipe['recipeInstructions'], null).toList(),
    yield: _strings(recipe['recipeYield']).firstOrNull,
    prepTime: _string(recipe['prepTime']),
    cookTime: _string(recipe['cookTime']),
    totalTime: _string(recipe['totalTime']),
    imageUrl: _image(recipe['image']),
  );
}

/// Steps from a string, a list, `HowToStep`s, or `HowToSection`s, which
/// become section headings.
Iterable<({String? section, String text})> _steps(
  Object? value,
  String? section,
) sync* {
  switch (value) {
    case final String text:
      // One string may hold every step, one per line.
      for (final line in text.split(RegExp(r'\n+'))) {
        final step = cleanText(line);
        if (step.isNotEmpty) yield (section: section, text: step);
      }
    case final List<Object?> items:
      for (final item in items) {
        yield* _steps(item, section);
      }
    case {'@type': 'HowToSection'} || {'itemListElement': List<Object?>()}:
      final node = value as Map<String, Object?>;
      yield* _steps(node['itemListElement'], _string(node['name']) ?? section);
    case final Map<String, Object?> node:
      final text = _string(node['text']) ?? _string(node['name']);
      if (text != null) yield (section: section, text: text);
  }
}

String? _image(Object? value) => switch (value) {
  final String url => url,
  final List<Object?> images => images.map(_image).nonNulls.firstOrNull,
  {'url': final String url} => url,
  _ => null,
};

String? _string(Object? value) => switch (value) {
  final String text when cleanText(text).isNotEmpty => cleanText(text),
  final num number => '$number',
  _ => null,
};

List<String> _strings(Object? value) => switch (value) {
  final List<Object?> items => items.map(_string).nonNulls.toList(),
  _ => [?_string(value)],
};
