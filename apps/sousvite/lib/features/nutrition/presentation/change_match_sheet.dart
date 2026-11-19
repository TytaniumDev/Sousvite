import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/nutrition/application/food_choice.dart';
import 'package:sousvite/features/nutrition/application/nutrition_actions.dart';
import 'package:sousvite/features/nutrition/application/nutrition_providers.dart';
import 'package:sousvite/features/nutrition/presentation/nutrition_words.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// Lets the user pick a different food for [lineId], correct its weight,
/// or leave it unmatched (PRD 7.4).
Future<void> showChangeMatchSheet(
  BuildContext context, {
  required RecipeId recipeId,
  required IngredientLineId lineId,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => _ChangeMatchSheet(recipeId: recipeId, lineId: lineId),
);

class const _ChangeMatchSheet({
  required final RecipeId recipeId,
  required final IngredientLineId lineId,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ChangeMatchSheet> createState() => _ChangeMatchSheetState();
}

class _ChangeMatchSheetState() extends ConsumerState<_ChangeMatchSheet> {
  late final IngredientLine? _line = ref
      .read(nutritionLinesProvider(widget.recipeId))
      .value
      ?.where((line) => line.id == widget.lineId)
      .firstOrNull;
  late final NutritionMatch? _match = ref
      .read(nutritionMatchesProvider(widget.recipeId))
      .value?[widget.lineId];
  late final _search = TextEditingController(
    text: _line?.name ?? _line?.rawText,
  );
  late final _grams = TextEditingController(
    text: switch (_match) {
      final match? => NutrientPrecision.grams.format(match.gramWeight),
      null => '',
    },
  );
  late String _query = _search.text;
  bool _needsGrams = false;

  @override
  void dispose() {
    _search.dispose();
    _grams.dispose();
    super.dispose();
  }

  double? get _enteredGrams => switch (double.tryParse(_grams.text.trim())) {
    final grams? when grams > 0 => grams,
    _ => null,
  };

  Future<void> _choose(FoodChoice choice) async {
    final line = _line;
    if (line == null) return;
    final actions = ref.read(nutritionActionsProvider);
    final grams = _enteredGrams ?? await actions.estimateWeight(line, choice);
    if (grams == null) {
      setState(() => _needsGrams = true);
      return;
    }
    await actions.chooseFood(line, choice, gramWeight: grams, current: _match);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _saveWeight(NutritionMatch match) async {
    final grams = _enteredGrams;
    if (grams == null) {
      setState(() => _needsGrams = true);
      return;
    }
    await ref.read(nutritionActionsProvider).setGramWeight(match, grams);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _leaveUnmatched(NutritionMatch match) async {
    await ref.read(nutritionActionsProvider).removeMatch(match);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final match = _match;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.space4,
        right: AppSpacing.space4,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.space4,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        spacing: AppSpacing.space3,
        children: [
          Text(
            l10n.nutrition_changeMatch,
            style: context.textStyles.titleLarge,
          ),
          Text(_line?.rawText ?? '', style: context.textStyles.bodyMedium),
          TextField(
            controller: _grams,
            keyboardType: const .numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.nutrition_weight,
              suffixText: l10n.nutrition_unitGrams,
              errorText: _needsGrams ? l10n.nutrition_weightNeeded : null,
            ),
            onChanged: (_) {
              if (_needsGrams) setState(() => _needsGrams = false);
            },
          ),
          if (match != null)
            Row(
              mainAxisAlignment: .end,
              spacing: AppSpacing.space2,
              children: [
                TextButton(
                  onPressed: () => _leaveUnmatched(match),
                  child: Text(l10n.nutrition_leaveUnmatched),
                ),
                FilledButton.tonal(
                  onPressed: () => _saveWeight(match),
                  child: Text(l10n.nutrition_saveWeight),
                ),
              ],
            ),
          TextField(
            controller: _search,
            textInputAction: .search,
            decoration: InputDecoration(
              labelText: l10n.nutrition_searchFoods,
              prefixIcon: const Icon(Symbols.search_rounded),
            ),
            onSubmitted: (query) => setState(() => _query = query),
          ),
          Flexible(
            child: _Results(query: _query, onChoose: _choose),
          ),
        ],
      ),
    );
  }
}

class const _Results({
  required final String query,
  required final ValueChanged<FoodChoice> onChoose,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(foodSearchProvider(query)),
    data: (choices) => choices.isEmpty
        ? Text(context.l10n.nutrition_noFoods)
        : FadingEdges(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: choices.length,
              itemBuilder: (context, index) {
                final choice = choices[index];
                final food = choice.food;
                final source = food.source == .openFoodFacts
                    ? MatchStatus.openFoodFacts
                    : MatchStatus.usda;
                return ListTile(
                  key: ValueKey(food.id),
                  title: Text(food.name),
                  subtitle: food.brand == null ? null : Text(food.brand!),
                  trailing: MatchStatusChip(
                    status: source,
                    label: context.l10n.matchStatus(source),
                  ),
                  onTap: () => onChoose(choice),
                );
              },
            ),
          ),
  );
}
