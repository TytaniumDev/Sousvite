import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/editor/application/editor_draft.dart';
import 'package:sousvite/features/editor/application/editor_outline.dart';
import 'package:sousvite/features/editor/presentation/draft_text_field.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/units/unit_words.dart';

/// Ingredients as plain lines, typed or pasted, each with its parsed
/// split underneath (DESIGN_SYSTEM.md §10.2), grouped into named
/// sections.
class const IngredientsEditor({
  /// The recipe being edited.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionIds = ref.watch(editorIngredientSectionIdsProvider(recipeId));
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        _LineGroup(recipeId: recipeId),
        for (final sectionId in sectionIds)
          _IngredientSectionEditor(
            key: ValueKey(sectionId),
            recipeId: recipeId,
            sectionId: sectionId,
          ),
        Align(
          alignment: .centerLeft,
          child: TextButton.icon(
            icon: const Icon(Symbols.playlist_add_rounded),
            label: Text(context.l10n.editor_addSection),
            onPressed: () => ref
                .read(editorDraftProvider(recipeId).notifier)
                .addIngredientSection(''),
          ),
        ),
      ],
    );
  }
}

class const _IngredientSectionEditor({
  required final RecipeId recipeId,
  required final IngredientSectionId sectionId,
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
            .ingredientSections
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
              Expanded(
                child: DraftTextField(
                  initialText: name,
                  label: l10n.editor_sectionName,
                  autofocus: name.isEmpty,
                  style: context.textStyles.titleMedium,
                  onChanged: (name) =>
                      draft.renameIngredientSection(sectionId, name),
                ),
              ),
              IconButton(
                tooltip: l10n.editor_removeSection,
                icon: const Icon(Symbols.delete_rounded),
                onPressed: () => draft.removeIngredientSection(sectionId),
              ),
            ],
          ),
          _LineGroup(recipeId: recipeId, sectionId: sectionId),
        ],
      ),
    );
  }
}

/// The lines of one section (or the loose lines), plus "Add ingredient".
class const _LineGroup({
  required final RecipeId recipeId,
  final IngredientSectionId? sectionId,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineIds = ref.watch(editorLineIdsProvider(recipeId, sectionId));
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        for (final lineId in lineIds)
          IngredientLineEditor(
            key: ValueKey(lineId),
            recipeId: recipeId,
            lineId: lineId,
          ),
        Align(
          alignment: .centerLeft,
          child: TextButton.icon(
            icon: const Icon(Symbols.add_rounded),
            label: Text(context.l10n.editor_addIngredient),
            onPressed: () => ref
                .read(editorDraftProvider(recipeId).notifier)
                .addLines([''], sectionId: sectionId),
          ),
        ),
      ],
    );
  }
}

/// One ingredient line. Pasting several lines splits them into one line
/// each; pressing Enter starts a new line below.
class const IngredientLineEditor({
  /// The recipe being edited.
  required final RecipeId recipeId,

  /// The line this edits.
  required final IngredientLineId lineId,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<IngredientLineEditor> createState() =>
      _IngredientLineEditorState();
}

class _IngredientLineEditorState() extends ConsumerState<IngredientLineEditor> {
  late final String _initialText =
      ref.read(editorLineProvider(widget.recipeId, widget.lineId))?.rawText ??
      '';
  late final _controller = TextEditingController(text: _initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changed(String text) {
    final draft = ref.read(editorDraftProvider(widget.recipeId).notifier);
    if (!text.contains('\n')) {
      draft.setLineText(widget.lineId, text);
      return;
    }
    final [first, ...rest] = text.split('\n');
    _controller.text = first;
    draft.setLineText(widget.lineId, first);
    final pasted = [
      for (final line in rest)
        if (line.trim().isNotEmpty) line.trim(),
    ];
    // Enter adds one empty line to type into; a paste adds its lines.
    draft.addLines(pasted.isEmpty ? [''] : pasted, afterLineId: widget.lineId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: _initialText.isEmpty,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: l10n.editor_ingredientHint,
                  ),
                  onChanged: _changed,
                ),
              ),
              IconButton(
                tooltip: l10n.editor_removeIngredient,
                icon: const Icon(Symbols.close_rounded),
                onPressed: () => ref
                    .read(editorDraftProvider(widget.recipeId).notifier)
                    .removeLine(widget.lineId),
              ),
            ],
          ),
          _SplitPreview(recipeId: widget.recipeId, lineId: widget.lineId),
        ],
      ),
    );
  }
}

/// How the parser split the line, so it can be checked and fixed.
class const _SplitPreview({
  required final RecipeId recipeId,
  required final IngredientLineId lineId,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final split = ref.watch(
      editorLineProvider(recipeId, lineId).select(
        (line) => line == null
            ? null
            : (
                quantity: line.quantity,
                unit: line.unit,
                countWord: line.countWord,
                name: line.name,
                preparation: line.preparation,
              ),
      ),
    );
    final name = split?.name;
    if (split == null || name == null) return const SizedBox.shrink();
    final quantity = split.quantity;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space1),
      child: IngredientSplitPreview(
        name: name,
        quantity: quantity,
        unit: quantity == null
            ? null
            : l10n.amountWord(split.unit, split.countWord, quantity),
        preparation: split.preparation,
        amountLabel: l10n.editor_amount,
        nameLabel: l10n.editor_ingredient,
        preparationLabel: l10n.editor_preparation,
      ),
    );
  }
}
