import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:recipe_import/src/snapshot_builder.dart';
import 'package:recipe_import/src/text_cleanup.dart';
import 'package:recipe_import/src/umami/umami_duration.dart';
import 'package:recipe_import/src/umami/umami_recipe.dart';

/// The recipe in one page of Umami's HTML export, as an unsaved draft with
/// new ids from [newId]. Null when the page has no recipe name.
///
/// The page lists details as `<p>Label: <strong>value</strong></p>`, then
/// `Ingredients` and `Directions` lists and `Notes` paragraphs, each under
/// an `<h2>`. A list item whose words are all bold or underlined is a
/// section heading. Umami's "Active Time" becomes the prep time.
UmamiRecipe? readUmamiHtml(
  String page, {
  required String Function() newId,
  required DateTime now,
}) {
  final body = html.parse(page).body;
  final title = cleanText(body?.querySelector('h1')?.text ?? '');
  if (body == null || title.isEmpty) return null;

  final details = <String, String>{};
  final lists = <String, List<SectionedText>>{};
  final notes = <String>[];
  String? imageUrl;
  String? part;
  for (final element in body.children) {
    final text = cleanText(element.text);
    switch (element.localName) {
      case 'h2':
        part = text;
      case 'p' when part == null:
        if (_detail.firstMatch(text) case final match?) {
          details[match[1]!] = match[2]!;
        }
      case 'p' when part == 'Notes' && text.isNotEmpty:
        notes.add(text);
      case 'ul' || 'ol' when part != null:
        lists[part] = _items(element);
      case 'img':
        imageUrl ??= element.attributes['src'];
    }
  }

  return (
    snapshot: buildSnapshot(
      title: title,
      ingredients: lists['Ingredients'] ?? const [],
      steps: [
        for (final (:section, :text)
            in lists['Directions'] ?? const <SectionedText>[])
          (section: section, text: text.replaceFirst(_stepNumber, '')),
      ],
      newId: newId,
      now: now,
      yield: details['Servings'],
      prepTime: _duration(details['Active Time']),
      totalTime: _duration(details['Total Time']),
      notes: notes.join('\n'),
    ),
    book: details['Recipe Book'],
    imageUrl: imageUrl,
  );
}

/// [recipe] as a page of Umami's HTML export, which [readUmamiHtml] reads
/// back. Sections become bold list items, after the loose lines. Umami has no
/// cook time, so only the prep ("Active") and total times are written.
String writeUmamiHtml(UmamiRecipe recipe) {
  final (:snapshot, :book, :imageUrl) = recipe;
  final RecipeSnapshot(
    recipe: Recipe(:title, :servings, :prepTime, :totalTime, :notes),
  ) = snapshot;
  final page = StringBuffer('<html><body><h1>${_text(title)}</h1>');
  void detail(String label, String value) =>
      page.write('<p>$label: <strong>${_text(value)}</strong></p>');

  if (book != null) page.write('<p>Recipe Book: <em>${_text(book)}</em></p>');
  detail(
    'Servings',
    '$servings ${servings == Quantity.one ? 'serving' : 'servings'}',
  );
  if (totalTime != null) detail('Total Time', formatUmamiDuration(totalTime));
  if (prepTime != null) detail('Active Time', formatUmamiDuration(prepTime));
  if (imageUrl != null) {
    page.write('<img alt="Recipe photo" src="${_attribute(imageUrl)}"/>');
  }
  page
    ..write('<h2>Ingredients</h2><ul>')
    ..writeAll(
      _listItems(
        [
          for (final line in snapshot.ingredientLines)
            (section: line.sectionId?.value, text: line.rawText),
        ],
        [
          for (final section in snapshot.ingredientSections)
            (id: section.id.value, name: section.name),
        ],
      ),
    )
    ..write('</ul><h2>Directions</h2><ol>')
    ..writeAll(
      _listItems(
        [
          for (final step in snapshot.steps)
            (section: step.sectionId?.value, text: step.text),
        ],
        [
          for (final section in snapshot.stepSections)
            (id: section.id.value, name: section.name),
        ],
      ),
    )
    ..write('</ol><h2>Notes</h2>');
  for (final line in notes.split('\n').where((l) => l.trim().isNotEmpty)) {
    page.write('<p><span>${_text(line)}</span></p>');
  }
  page.write('</body></html>');
  return page.toString();
}

/// List items for [items], loose ones first, then each of [sections] in
/// order under a bold heading item. Lines whose section is missing count
/// as loose.
Iterable<String> _listItems(
  Iterable<({String? section, String text})> items,
  Iterable<({String id, String name})> sections,
) sync* {
  final names = {for (final (:id, :name) in sections) id: name};
  final bySection = <String?, List<String>>{};
  for (final (:section, :text) in items) {
    (bySection[names.containsKey(section) ? section : null] ??= []).add(text);
  }
  yield* (bySection[null] ?? const []).map(_item);
  for (final MapEntry(key: id, value: name) in names.entries) {
    if (bySection[id] case final texts?) {
      yield '<li><p><strong><span>${_text(name)}</span></strong></p></li>';
      yield* texts.map(_item);
    }
  }
}

String _item(String text) => '<li><p><span>${_text(text)}</span></p></li>';

/// A list's items, with the section each sits in. A heading item names the
/// section of the items after it. A heading right after another, like
/// "Method:" under "Slaw:", is a sub-heading, so the first one names the
/// section.
List<SectionedText> _items(Element list) {
  final items = <SectionedText>[];
  String? section;
  var afterHeading = false;
  for (final item in list.children.where((e) => e.localName == 'li')) {
    final text = cleanText(item.text);
    if (text.isEmpty) continue;
    final isHeading = _isHeading(item);
    if (isHeading && !afterHeading) {
      section = text.replaceFirst(RegExp(r'\s*:$'), '');
    } else if (!isHeading) {
      items.add((section: section, text: text));
    }
    afterHeading = isHeading;
  }
  return items;
}

/// Whether every word of [item] is bold or underlined. Punctuation outside
/// the emphasis, like the colon in `<strong>Potatoes</strong>:`, doesn't
/// count.
bool _isHeading(Element item) {
  final words = _textNodes(item)
      .where((node) => node.text.contains(_wordCharacter))
      .toList();
  return words.isNotEmpty &&
      words.every((node) => _emphasized(node.parent, within: item));
}

bool _emphasized(Element? element, {required Element within}) {
  for (var e = element; e != null && e != within; e = e.parent) {
    if (e.localName == 'strong' ||
        e.localName == 'b' ||
        (e.attributes['style'] ?? '').contains('underline')) {
      return true;
    }
  }
  return false;
}

Iterable<Text> _textNodes(Node node) sync* {
  for (final child in node.nodes) {
    if (child is Text) {
      yield child;
    } else {
      yield* _textNodes(child);
    }
  }
}

String _text(String text) =>
    const HtmlEscape(HtmlEscapeMode.element).convert(text);

String _attribute(String text) =>
    const HtmlEscape(HtmlEscapeMode.attribute).convert(text);

/// "Servings: 4 servings" → label and value.
final _detail = RegExp(r'^([A-Za-z ]+):\s*(.*)$');

/// A letter or digit, in any script.
final _wordCharacter = RegExp(r'[\p{L}\p{N}]', unicode: true);

/// A step number some recipes type at the start of each step: "1. ".
final _stepNumber = RegExp(r'^\d+\.\s*');

Duration? _duration(String? text) =>
    text == null ? null : parseUmamiDuration(text);
