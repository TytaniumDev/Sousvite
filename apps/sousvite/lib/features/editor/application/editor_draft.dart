import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingredient_parser/ingredient_parser.dart';
import 'package:recipe_import/recipe_import.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/editor/application/ingredient_line_parser.dart';
import 'package:uuid/uuid.dart';

part 'editor_draft.g.dart';

/// The recipe being edited, and how it was saved (null for a new one).
typedef EditorState = ({RecipeSnapshot draft, RecipeSnapshot? saved});

/// The recipe being edited. Changes stay in this draft until [save]
/// writes them in one transaction; leaving without saving drops them.
///
/// A recipe id that isn't saved yet opens a new recipe, with a "Prep"
/// step section to start (DESIGN_SYSTEM.md §10.2).
@riverpod
class EditorDraft() extends _$EditorDraft {
  @override
  Future<EditorState> build(RecipeId recipeId) async {
    final repository = ref.watch(recipeRepositoryProvider);
    final recipe = await repository.getRecipe(recipeId);
    if (recipe == null) return (draft: _blank(recipeId), saved: null);
    final snapshot = RecipeSnapshot(
      recipe: recipe,
      ingredientSections: await repository
          .watchIngredientSections(recipeId)
          .first,
      ingredientLines: await repository.watchIngredientLines(recipeId).first,
      stepSections: await repository.watchStepSections(recipeId).first,
      steps: await repository.watchSteps(recipeId).first,
    );
    return (draft: snapshot, saved: snapshot);
  }

  RecipeSnapshot _blank(RecipeId recipeId) {
    final now = clock.now();
    return RecipeSnapshot(
      recipe: Recipe(
        id: recipeId,
        title: '',
        servings: Quantity(4),
        createdAt: now,
        updatedAt: now,
      ),
      stepSections: [
        StepSection(
          id: StepSectionId(_newId()),
          recipeId: recipeId,
          name: 'Prep',
          sortKey: SortKey.between(null, null),
        ),
      ],
    );
  }

  static String _newId() => const Uuid().v4();

  void _edit(RecipeSnapshot Function(RecipeSnapshot draft) change) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData((draft: change(current.draft), saved: current.saved));
  }

  // Recipe fields.

  void setTitle(String title) =>
      _edit((d) => d.copyWith(recipe: d.recipe.copyWith(title: title)));

  void setServings(Quantity servings) {
    if (servings <= Quantity.zero) return;
    _edit((d) => d.copyWith(recipe: d.recipe.copyWith(servings: servings)));
  }

  void setTotalTime(Duration? time) =>
      _edit((d) => d.copyWith(recipe: d.recipe.copyWith(totalTime: time)));

  void setNotes(String notes) =>
      _edit((d) => d.copyWith(recipe: d.recipe.copyWith(notes: notes)));

  // Ingredients.

  /// Sets a line's text and splits it into parts with the parser.
  void setLineText(IngredientLineId lineId, String text) {
    final parsed = ref.read(ingredientLineParserProvider)(text);
    _edit(
      (d) => d.copyWith(
        ingredientLines: [
          for (final line in d.ingredientLines)
            if (line.id == lineId) _withParsed(line, text, parsed) else line,
        ],
      ),
    );
  }

  /// [line] with [text] and the parts the parser read in it, filled in
  /// the same way as imported lines.
  static IngredientLine _withParsed(
    IngredientLine line,
    String text,
    ParsedLine parsed,
  ) => withParsedParts(line.copyWith(rawText: text), parsed);

  /// Adds lines for [texts] after [afterLineId] in its section, or at the
  /// end of [sectionId]. Pasting several lines adds one line each, and a
  /// pasted heading ("For the sauce:") starts a new section at the end
  /// for the lines after it. Returns the new lines' ids.
  List<IngredientLineId> addLines(
    List<String> texts, {
    IngredientSectionId? sectionId,
    IngredientLineId? afterLineId,
  }) {
    final draft = state.value?.draft;
    if (draft == null) return const [];
    final parse = ref.read(ingredientLineParserProvider);
    final after = draft.ingredientLines.firstWhereOrNull(
      (l) => l.id == afterLineId,
    );
    final section = after?.sectionId ?? sectionId;
    final group = [
      for (final line in draft.ingredientLines)
        if (line.sectionId == section) line,
    ];
    final index = after == null ? group.length : group.indexOf(after) + 1;
    var before = index == 0 ? null : group[index - 1].sortKey;
    var next = index < group.length ? group[index].sortKey : null;
    var lineSection = section;
    var lastSectionKey = draft.ingredientSections.lastOrNull?.sortKey;
    final sections = <IngredientSection>[];
    final added = <IngredientLine>[];
    for (final text in texts) {
      final parsed = parse(text);
      if (parsed.heading case final heading? when texts.length > 1) {
        // A new section goes last, so its lines start a fresh group.
        lastSectionKey = SortKey.between(lastSectionKey, null);
        final newSection = IngredientSection(
          id: IngredientSectionId(_newId()),
          recipeId: draft.recipe.id,
          name: _capitalized(heading),
          sortKey: lastSectionKey,
        );
        sections.add(newSection);
        lineSection = newSection.id;
        before = null;
        next = null;
        continue;
      }
      final key = SortKey.between(before, next);
      before = key;
      added.add(
        _withParsed(
          IngredientLine(
            id: IngredientLineId(_newId()),
            recipeId: draft.recipe.id,
            rawText: text,
            sortKey: key,
            sectionId: lineSection,
          ),
          text,
          parsed,
        ),
      );
    }
    _edit(
      (d) => d.copyWith(
        ingredientSections: [...d.ingredientSections, ...sections],
        ingredientLines: [
          ...d.ingredientLines,
          ...added,
        ].sortedBy((l) => l.sortKey.value),
      ),
    );
    return [for (final line in added) line.id];
  }

  static String _capitalized(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  void removeLine(IngredientLineId lineId) => _edit(
    (d) => d.copyWith(
      ingredientLines: [
        for (final line in d.ingredientLines)
          if (line.id != lineId) line,
      ],
    ),
  );

  /// Adds an ingredient section named [name] at the end. Returns its id.
  IngredientSectionId? addIngredientSection(String name) {
    final draft = state.value?.draft;
    if (draft == null) return null;
    final section = IngredientSection(
      id: IngredientSectionId(_newId()),
      recipeId: draft.recipe.id,
      name: name,
      sortKey: SortKey.between(
        draft.ingredientSections.lastOrNull?.sortKey,
        null,
      ),
    );
    _edit(
      (d) => d.copyWith(ingredientSections: [...d.ingredientSections, section]),
    );
    return section.id;
  }

  void renameIngredientSection(IngredientSectionId sectionId, String name) =>
      _edit(
        (d) => d.copyWith(
          ingredientSections: [
            for (final section in d.ingredientSections)
              if (section.id == sectionId)
                section.copyWith(name: name)
              else
                section,
          ],
        ),
      );

  /// Removes a section and its lines.
  void removeIngredientSection(IngredientSectionId sectionId) => _edit(
    (d) => d.copyWith(
      ingredientSections: [
        for (final section in d.ingredientSections)
          if (section.id != sectionId) section,
      ],
      ingredientLines: [
        for (final line in d.ingredientLines)
          if (line.sectionId != sectionId) line,
      ],
    ),
  );

  // Steps.

  void setStepText(RecipeStepId stepId, String text) => _edit(
    (d) => d.copyWith(
      steps: [
        for (final step in d.steps)
          if (step.id == stepId) step.copyWith(text: text) else step,
      ],
    ),
  );

  /// Adds a step at the end of [sectionId], or of the loose steps. Returns
  /// its id.
  RecipeStepId? addStep({StepSectionId? sectionId, String text = ''}) {
    final draft = state.value?.draft;
    if (draft == null) return null;
    final last = draft.steps.lastWhereOrNull((s) => s.sectionId == sectionId);
    final step = RecipeStep(
      id: RecipeStepId(_newId()),
      recipeId: draft.recipe.id,
      text: text,
      sortKey: SortKey.between(last?.sortKey, null),
      sectionId: sectionId,
    );
    _edit(
      (d) => d.copyWith(
        steps: [...d.steps, step].sortedBy((s) => s.sortKey.value),
      ),
    );
    return step.id;
  }

  void removeStep(RecipeStepId stepId) => _edit(
    (d) => d.copyWith(
      steps: [
        for (final step in d.steps)
          if (step.id != stepId) step,
      ],
    ),
  );

  /// Adds a step section named [name] at the end. Returns its id.
  StepSectionId? addStepSection(String name) {
    final draft = state.value?.draft;
    if (draft == null) return null;
    final section = StepSection(
      id: StepSectionId(_newId()),
      recipeId: draft.recipe.id,
      name: name,
      sortKey: SortKey.between(draft.stepSections.lastOrNull?.sortKey, null),
    );
    _edit((d) => d.copyWith(stepSections: [...d.stepSections, section]));
    return section.id;
  }

  void renameStepSection(StepSectionId sectionId, String name) => _edit(
    (d) => d.copyWith(
      stepSections: [
        for (final section in d.stepSections)
          if (section.id == sectionId)
            section.copyWith(name: name)
          else
            section,
      ],
    ),
  );

  /// Removes a section and its steps.
  void removeStepSection(StepSectionId sectionId) => _edit(
    (d) => d.copyWith(
      stepSections: [
        for (final section in d.stepSections)
          if (section.id != sectionId) section,
      ],
      steps: [
        for (final step in d.steps)
          if (step.sectionId != sectionId) step,
      ],
    ),
  );

  /// Moves a step section from [oldIndex] to [newIndex], its place once
  /// moved (as `onReorderItem` reports it). Only the moved section gets a
  /// new sort key.
  void moveStepSection(int oldIndex, int newIndex) {
    final draft = state.value?.draft;
    if (draft == null) return;
    final sections = [...draft.stepSections];
    final target = newIndex.clamp(0, sections.length - 1);
    if (target == oldIndex) return;
    final moved = sections.removeAt(oldIndex);
    final before = target == 0 ? null : sections[target - 1].sortKey;
    final after = target < sections.length ? sections[target].sortKey : null;
    sections.insert(
      target,
      moved.copyWith(sortKey: SortKey.between(before, after)),
    );
    _edit((d) => d.copyWith(stepSections: sections));
  }

  // Saving.

  /// Writes the draft in one transaction, removing the parts deleted
  /// while editing. Blank lines and steps are dropped. Does nothing
  /// without a title.
  Future<bool> save() async {
    final draft = state.value?.draft;
    if (draft == null || draft.recipe.title.trim().isEmpty) return false;
    final repository = ref.read(recipeRepositoryProvider);
    final saved = state.value?.saved;
    final cleaned = draft.copyWith(
      recipe: draft.recipe.copyWith(
        title: draft.recipe.title.trim(),
        updatedAt: clock.now(),
      ),
      ingredientLines: [
        for (final line in draft.ingredientLines)
          if (line.rawText.trim().isNotEmpty) line,
      ],
      steps: [
        for (final step in draft.steps)
          if (step.text.trim().isNotEmpty) step,
      ],
    );
    if (saved != null) {
      for (final id in _removed(
        saved.ingredientLines,
        cleaned.ingredientLines,
        (l) => l.id,
      )) {
        await repository.deleteIngredientLine(id);
      }
      for (final id in _removed(
        saved.ingredientSections,
        cleaned.ingredientSections,
        (s) => s.id,
      )) {
        await repository.deleteIngredientSection(id);
      }
      for (final id in _removed(saved.steps, cleaned.steps, (s) => s.id)) {
        await repository.deleteStep(id);
      }
      for (final id in _removed(
        saved.stepSections,
        cleaned.stepSections,
        (s) => s.id,
      )) {
        await repository.deleteStepSection(id);
      }
    }
    await repository.saveSnapshot(cleaned);
    state = AsyncData((draft: cleaned, saved: cleaned));
    return true;
  }

  static Iterable<I> _removed<T, I>(
    List<T> before,
    List<T> after,
    I Function(T item) id,
  ) {
    final kept = {for (final item in after) id(item)};
    return [
      for (final item in before)
        if (!kept.contains(id(item))) id(item),
    ];
  }
}

/// Whether the draft differs from what is saved. A new recipe counts as
/// changed once it has a name.
@riverpod
bool editorHasChanges(Ref ref, RecipeId recipeId) => ref.watch(
  editorDraftProvider(recipeId).select((state) {
    final value = state.value;
    if (value == null) return false;
    final saved = value.saved;
    return saved == null
        ? value.draft.recipe.title.trim().isNotEmpty
        : value.draft != saved;
  }),
);

/// Whether the recipe has never been saved.
@riverpod
bool editorIsNew(Ref ref, RecipeId recipeId) => ref.watch(
  editorDraftProvider(recipeId)
      .select((state) => state.value != null && state.value!.saved == null),
);
