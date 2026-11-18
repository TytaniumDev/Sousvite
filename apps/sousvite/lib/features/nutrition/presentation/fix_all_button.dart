import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/nutrition/presentation/auto_match_feedback.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Matches every unmatched ingredient of a recipe that clearly fits a USDA
/// food. The rest stay unmatched for the user to fix.
class const FixAllButton({
  /// The recipe whose ingredients this matches.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<FixAllButton> createState() => _FixAllButtonState();
}

class _FixAllButtonState() extends ConsumerState<FixAllButton> {
  var _running = false;

  Future<void> _fixAll() async {
    setState(() => _running = true);
    try {
      await runAutoMatch(
        context,
        ref,
        (autoMatch) => autoMatch.matchRecipe(widget.recipeId),
      );
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: _running ? null : _fixAll,
    child: Text(context.l10n.nutrition_fixAll),
  );
}
