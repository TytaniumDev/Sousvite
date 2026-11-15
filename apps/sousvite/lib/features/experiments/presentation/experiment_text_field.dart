import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/experiments/application/experiment_actions.dart';
import 'package:sousvite/features/experiments/application/history_providers.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Which text an [ExperimentTextField] edits.
enum ExperimentTextKind() {
  /// What changed: "Swapped butter for olive oil".
  changeDescription,

  /// How it went.
  notes,
}

/// One of an experiment's text fields. Starts from the saved text and
/// saves when it loses focus, when the keyboard's done key is pressed, and
/// when the screen closes, so nothing typed is lost.
class const ExperimentTextField({
  required final RecipeId recipeId,
  required final ExperimentId experimentId,

  /// Which text this field edits.
  required final ExperimentTextKind field,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<ExperimentTextField> createState() =>
      _ExperimentTextFieldState();
}

class _ExperimentTextFieldState() extends ConsumerState<ExperimentTextField> {
  late final TextEditingController _controller;
  late final ExperimentActions _actions;
  final _focus = FocusNode();
  var _saved = '';

  @override
  void initState() {
    super.initState();
    // Read once: the field owns its text while it is open, so later saves
    // don't move the cursor.
    final experiment = ref
        .read(historyExperimentProvider(widget.recipeId, widget.experimentId))
        .value;
    _saved = switch (widget.field) {
      .changeDescription => experiment?.changeDescription ?? '',
      .notes => experiment?.notes ?? '',
    };
    _controller = TextEditingController(text: _saved);
    _actions = ref.read(experimentActionsProvider);
    _focus.addListener(() {
      if (!_focus.hasFocus) _save();
    });
  }

  void _save() {
    final text = _controller.text;
    if (text == _saved) return;
    _saved = text;
    final id = widget.experimentId;
    switch (widget.field) {
      case .changeDescription:
        unawaited(_actions.describe(id, changeDescription: text));
      case .notes:
        unawaited(_actions.describe(id, notes: text));
    }
  }

  @override
  void dispose() {
    _save();
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isNotes = widget.field == .notes;
    return TextField(
      controller: _controller,
      focusNode: _focus,
      textCapitalization: .sentences,
      minLines: isNotes ? 3 : 1,
      maxLines: isNotes ? null : 1,
      textInputAction: isNotes ? .newline : .done,
      onSubmitted: (_) => _save(),
      decoration: InputDecoration(
        labelText: isNotes
            ? l10n.experiments_howItWent
            : l10n.experiments_whatChanged,
        hintText: isNotes ? null : l10n.experiments_whatChangedHint,
      ),
    );
  }
}
