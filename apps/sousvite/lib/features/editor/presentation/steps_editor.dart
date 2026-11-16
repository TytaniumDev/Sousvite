import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/editor/application/editor_draft.dart';
import 'package:sousvite/features/editor/application/editor_outline.dart';
import 'package:sousvite/features/editor/presentation/draft_text_field.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Steps, grouped into named sections that reorder by drag handle
/// (DESIGN_SYSTEM.md §10.2).
class const StepsEditor({
  /// The recipe being edited.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionIds = ref.watch(editorStepSectionIdsProvider(recipeId));
    final draft = ref.read(editorDraftProvider(recipeId).notifier);
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        _StepGroup(recipeId: recipeId),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: draft.moveStepSection,
          children: [
            for (final (index, sectionId) in sectionIds.indexed)
              _StepSectionEditor(
                key: ValueKey(sectionId),
                recipeId: recipeId,
                sectionId: sectionId,
                index: index,
              ),
          ],
        ),
        Align(
          alignment: .centerLeft,
          child: TextButton.icon(
            icon: const Icon(Symbols.playlist_add_rounded),
            label: Text(context.l10n.editor_addSection),
            onPressed: () => draft.addStepSection(''),
          ),
        ),
      ],
    );
  }
}

class const _StepSectionEditor({
  required final RecipeId recipeId,
  required final StepSectionId sectionId,
  required final int index,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.read(editorDraftProvider(recipeId).notifier);
    final name =
        ref
            .read(editorDraftProvider(recipeId))
            .value
            ?.draft
            .stepSections
            .where((s) => s.id == sectionId)
            .firstOrNull
            ?.name ??
        '';
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Semantics(
                  label: l10n.editor_reorderSection(name),
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.space3),
                    child: Icon(Symbols.drag_indicator_rounded),
                  ),
                ),
              ),
              Expanded(
                child: DraftTextField(
                  initialText: name,
                  label: l10n.editor_sectionName,
                  autofocus: name.isEmpty,
                  style: context.textStyles.titleMedium,
                  onChanged: (name) => draft.renameStepSection(sectionId, name),
                ),
              ),
              IconButton(
                tooltip: l10n.editor_removeSection,
                icon: const Icon(Symbols.delete_rounded),
                onPressed: () => draft.removeStepSection(sectionId),
              ),
            ],
          ),
          _StepGroup(recipeId: recipeId, sectionId: sectionId),
        ],
      ),
    );
  }
}

/// The steps of one section (or the loose steps), plus "Add step".
class const _StepGroup({
  required final RecipeId recipeId,
  final StepSectionId? sectionId,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepIds = ref.watch(editorStepIdsProvider(recipeId, sectionId));
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        for (final stepId in stepIds)
          StepEditor(key: ValueKey(stepId), recipeId: recipeId, stepId: stepId),
        Align(
          alignment: .centerLeft,
          child: TextButton.icon(
            icon: const Icon(Symbols.add_rounded),
            label: Text(context.l10n.editor_addStep),
            onPressed: () => ref
                .read(editorDraftProvider(recipeId).notifier)
                .addStep(sectionId: sectionId),
          ),
        ),
      ],
    );
  }
}

/// One step's text. Typing never rebuilds it.
class const StepEditor({
  /// The recipe being edited.
  required final RecipeId recipeId,

  /// The step this edits.
  required final RecipeStepId stepId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.read(editorDraftProvider(recipeId).notifier);
    final text =
        ref
            .read(editorDraftProvider(recipeId))
            .value
            ?.draft
            .steps
            .where((s) => s.id == stepId)
            .firstOrNull
            ?.text ??
        '';
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Expanded(
            child: DraftTextField(
              initialText: text,
              hint: l10n.editor_stepHint,
              maxLines: null,
              autofocus: text.isEmpty,
              onChanged: (text) => draft.setStepText(stepId, text),
            ),
          ),
          IconButton(
            tooltip: l10n.editor_removeStep,
            icon: const Icon(Symbols.close_rounded),
            onPressed: () => draft.removeStep(stepId),
          ),
        ],
      ),
    );
  }
}
