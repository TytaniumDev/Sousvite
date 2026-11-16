import 'package:collection/collection.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/features/editor/application/editor_draft.dart';

part 'editor_outline.g.dart';

// The draft's structure as id lists, so a list rebuilds only when items
// are added, removed, or moved, never while one is typed in.

/// The draft's ingredient sections, in order.
@riverpod
class EditorIngredientSectionIds() extends _$EditorIngredientSectionIds {
  @override
  List<IngredientSectionId> build(RecipeId recipeId) => [
    for (final section
        in ref
                .watch(editorDraftProvider(recipeId))
                .value
                ?.draft
                .ingredientSections ??
            const <IngredientSection>[])
      section.id,
  ];

  @override
  bool updateShouldNotify(
    List<IngredientSectionId> previous,
    List<IngredientSectionId> next,
  ) => !const ListEquality<IngredientSectionId>().equals(previous, next);
}

/// The draft's ingredient lines in [sectionId], or the loose lines when
/// it is null.
@riverpod
class EditorLineIds() extends _$EditorLineIds {
  @override
  List<IngredientLineId> build(
    RecipeId recipeId,
    IngredientSectionId? sectionId,
  ) => [
    for (final line
        in ref
                .watch(editorDraftProvider(recipeId))
                .value
                ?.draft
                .ingredientLines ??
            const <IngredientLine>[])
      if (line.sectionId == sectionId) line.id,
  ];

  @override
  bool updateShouldNotify(
    List<IngredientLineId> previous,
    List<IngredientLineId> next,
  ) => !const ListEquality<IngredientLineId>().equals(previous, next);
}

/// The draft's step sections, in order.
@riverpod
class EditorStepSectionIds() extends _$EditorStepSectionIds {
  @override
  List<StepSectionId> build(RecipeId recipeId) => [
    for (final section
        in ref.watch(editorDraftProvider(recipeId)).value?.draft.stepSections ??
            const <StepSection>[])
      section.id,
  ];

  @override
  bool updateShouldNotify(
    List<StepSectionId> previous,
    List<StepSectionId> next,
  ) => !const ListEquality<StepSectionId>().equals(previous, next);
}

/// The draft's steps in [sectionId], or the loose steps when it is null.
@riverpod
class EditorStepIds() extends _$EditorStepIds {
  @override
  List<RecipeStepId> build(RecipeId recipeId, StepSectionId? sectionId) => [
    for (final step
        in ref.watch(editorDraftProvider(recipeId)).value?.draft.steps ??
            const <RecipeStep>[])
      if (step.sectionId == sectionId) step.id,
  ];

  @override
  bool updateShouldNotify(
    List<RecipeStepId> previous,
    List<RecipeStepId> next,
  ) => !const ListEquality<RecipeStepId>().equals(previous, next);
}

/// One draft line, or null once it is removed.
@riverpod
IngredientLine? editorLine(
  Ref ref,
  RecipeId recipeId,
  IngredientLineId lineId,
) => ref.watch(
  editorDraftProvider(recipeId).select(
    (draft) => draft.value?.draft.ingredientLines.firstWhereOrNull(
      (l) => l.id == lineId,
    ),
  ),
);
