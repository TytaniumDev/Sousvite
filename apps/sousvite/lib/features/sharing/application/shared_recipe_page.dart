import 'package:domain/domain.dart';
import 'package:sousvite/app/services/sharing_service.dart';

/// [snapshot] as plain text for a view-only link page (PRD 7.10).
///
/// Ingredient lines show what the user typed, so the page matches the
/// recipe as written. Parts outside any section come first, then each
/// section in order. [yieldText] is the localized servings line.
SharedRecipePage sharedRecipePage(
  RecipeSnapshot snapshot, {
  required String? yieldText,
}) {
  final recipe = snapshot.recipe;
  return SharedRecipePage(
    title: recipe.title,
    yieldText: yieldText,
    sourceName: recipe.sourceName,
    sourceUrl: recipe.sourceUrl,
    ingredients: _sections(
      sections: [for (final s in snapshot.ingredientSections) (s.id, s.name)],
      items: [
        for (final l in snapshot.ingredientLines) (l.sectionId, l.rawText),
      ],
    ),
    steps: _sections(
      sections: [for (final s in snapshot.stepSections) (s.id, s.name)],
      items: [for (final s in snapshot.steps) (s.sectionId, s.text)],
    ),
  );
}

/// Groups [items] under [sections], leaving out empty ones. Items whose
/// section is null or missing come first, untitled.
List<SharedSection> _sections<Id>({
  required List<(Id, String)> sections,
  required List<(Id?, String)> items,
}) {
  final known = {for (final (id, _) in sections) id};
  final loose = [
    for (final (sectionId, text) in items)
      if (!known.contains(sectionId)) text,
  ];
  return [
    if (loose.isNotEmpty) SharedSection(title: null, items: loose),
    for (final (id, name) in sections)
      if (items.where((item) => item.$1 == id).isNotEmpty)
        SharedSection(
          title: name.isEmpty ? null : name,
          items: [
            for (final (sectionId, text) in items)
              if (sectionId == id) text,
          ],
        ),
  ];
}
