import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/cooking/cooking.dart';
import 'package:sousvite/features/editor/editor.dart';
import 'package:sousvite/features/experiments/application/experiment_actions.dart';
import 'package:sousvite/features/experiments/application/history_providers.dart';
import 'package:sousvite/features/experiments/presentation/experiment_text_field.dart';
import 'package:sousvite/features/experiments/presentation/outcome_label.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// One experiment: what changed and how it went, ways to edit and cook it,
/// and the choice to make it the recipe or keep it logged (PRD 7.11).
class const ExperimentScreen({
  /// The recipe the experiment belongs to.
  required final RecipeId recipeId,

  /// The experiment shown.
  required final ExperimentId experimentId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = historyExperimentProvider(recipeId, experimentId);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.experiments_badge)),
      body: AsyncValueView(
        // Only whether it exists: each part below watches its own fields.
        value: ref.watch(provider.select((e) => e.whenData((e) => e != null))),
        data: (exists) => exists
            ? ListView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                children: [
                  _Outcome(provider: provider),
                  const SizedBox(height: AppSpacing.space4),
                  ExperimentTextField(
                    recipeId: recipeId,
                    experimentId: experimentId,
                    field: .changeDescription,
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  ExperimentTextField(
                    recipeId: recipeId,
                    experimentId: experimentId,
                    field: .notes,
                  ),
                  const SizedBox(height: AppSpacing.space6),
                  _WorkingCopyActions(provider: provider),
                  const SizedBox(height: AppSpacing.space6),
                  _Decision(provider: provider),
                ],
              )
            : Center(child: Text(l10n.experiments_notFound)),
      ),
    );
  }
}

/// The badge and how the experiment turned out.
class const _Outcome({required final HistoryExperimentProvider provider})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outcome = ref.watch(provider.select((e) => e.value?.outcome));
    if (outcome == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Row(
      children: [
        ExperimentBadge(label: l10n.experiments_badge),
        const SizedBox(width: AppSpacing.space2),
        Text(outcomeLabel(l10n, outcome), style: context.textStyles.bodyMedium),
      ],
    );
  }
}

/// Edit or cook the experiment's own copy of the recipe.
class const _WorkingCopyActions({
  required final HistoryExperimentProvider provider,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workingRecipeId = ref.watch(
      provider.select((e) => e.value?.workingRecipeId),
    );
    if (workingRecipeId == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.space2,
      runSpacing: AppSpacing.space2,
      children: [
        OutlinedButton(
          onPressed: () =>
              context.push<void>(EditorRoutes.location(workingRecipeId)),
          child: Text(l10n.experiments_edit),
        ),
        OutlinedButton(
          onPressed: () =>
              context.push<void>(CookingRoutes.location(workingRecipeId)),
          child: Text(l10n.experiments_cook),
        ),
      ],
    );
  }
}

/// Make it the recipe, or keep it as a logged attempt. Only while the
/// experiment is still open.
class const _Decision({required final HistoryExperimentProvider provider})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(
      provider.select((e) => e.value?.outcome == ExperimentOutcome.open),
    );
    if (!open) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        FilledButton(
          onPressed: () => _decide(
            context,
            ref,
            l10n.experiments_promoted,
            (actions, experiment) => actions.promote(experiment.id),
          ),
          child: Text(l10n.experiments_promote),
        ),
        const SizedBox(height: AppSpacing.space2),
        FilledButton.tonal(
          onPressed: () => _decide(
            context,
            ref,
            l10n.experiments_outcomeKept,
            (actions, experiment) => actions.keep(experiment),
          ),
          child: Text(l10n.experiments_keep),
        ),
      ],
    );
  }

  Future<void> _decide(
    BuildContext context,
    WidgetRef ref,
    String done,
    Future<void> Function(ExperimentActions, Experiment) action,
  ) async {
    final experiment = ref.read(provider).value;
    if (experiment == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    await action(ref.read(experimentActionsProvider), experiment);
    messenger.showSnackBar(SnackBar(content: Text(done)));
    if (router.canPop()) router.pop();
  }
}
