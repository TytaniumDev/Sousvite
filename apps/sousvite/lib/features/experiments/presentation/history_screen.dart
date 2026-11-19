import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/experiments/application/experiment_actions.dart';
import 'package:sousvite/features/experiments/application/history_providers.dart';
import 'package:sousvite/features/experiments/application/history_ref.dart';
import 'package:sousvite/features/experiments/experiments_routes.dart';
import 'package:sousvite/features/experiments/presentation/outcome_label.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// A recipe's history: past versions and experiments, newest first, and
/// the button that starts a new experiment (PRD 7.11).
class const HistoryScreen({
  /// The recipe whose history this shows.
  required final RecipeId recipeId,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.experiments_title)),
    body: _Timeline(recipeId: recipeId),
    floatingActionButton: _StartButton(recipeId: recipeId),
  );
}

class const _StartButton({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      FloatingActionButton.extended(
        onPressed: () async {
          final router = GoRouter.of(context);
          final experiment = await ref
              .read(experimentActionsProvider)
              .start(recipeId);
          await router.push<void>(
            ExperimentsRoutes.experimentLocation(recipeId, experiment.id),
          );
        },
        icon: const Icon(Symbols.science_rounded),
        label: Text(context.l10n.experiments_start),
      );
}

class const _Timeline({required final RecipeId recipeId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AsyncValueView(
      value: ref.watch(historyTimelineProvider(recipeId)),
      error: (_, _) => ErrorState(
        title: l10n.experiments_errorTitle,
        message: l10n.experiments_errorMessage,
        retryLabel: l10n.common_retry,
        onRetry: () => ref
          ..invalidate(recipeVersionsProvider(recipeId))
          ..invalidate(recipeExperimentsProvider(recipeId)),
      ),
      data: (timeline) => timeline.entries.isEmpty
          ? EmptyState(
              icon: Symbols.history_rounded,
              title: l10n.experiments_emptyTitle,
              message: l10n.experiments_emptyMessage,
            )
          : ReadingColumn(
              builder: (context, insets) => FadingEdges(
                child: ListView(
                  padding: insets,
                  children: [
                    for (final entry in timeline.entries)
                      switch (entry) {
                        VersionRef(:final id) => _VersionTile(
                          key: ValueKey(id),
                          recipeId: recipeId,
                          versionId: id,
                        ),
                        ExperimentRef(:final id) => _ExperimentTile(
                          key: ValueKey(id),
                          recipeId: recipeId,
                          experimentId: id,
                        ),
                      },
                  ],
                ),
              ),
            ),
    );
  }
}

class const _VersionTile({
  required final RecipeId recipeId,
  required final RecipeVersionId versionId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(
      historyVersionProvider(recipeId, versionId).select((v) => v.value),
    );
    if (version == null) return const SizedBox.shrink();
    return ListTile(
      leading: const Icon(Symbols.history_rounded),
      title: Text(
        version.summary.isEmpty
            ? context.l10n.experiments_savedVersion
            : version.summary,
      ),
      subtitle: Text(
        MaterialLocalizations.of(context).formatMediumDate(version.createdAt),
      ),
      onTap: () => context.push<void>(
        ExperimentsRoutes.versionLocation(recipeId, versionId),
      ),
    );
  }
}

class const _ExperimentTile({
  required final RecipeId recipeId,
  required final ExperimentId experimentId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiment = ref.watch(
      historyExperimentProvider(recipeId, experimentId).select((e) => e.value),
    );
    if (experiment == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(experiment.createdAt);
    return ListTile(
      leading: Icon(Symbols.science_rounded, color: context.colors.tertiary),
      title: Text(
        experiment.changeDescription.isEmpty
            ? l10n.experiments_untitled
            : experiment.changeDescription,
      ),
      subtitle: Text('${outcomeLabel(l10n, experiment.outcome)} · $date'),
      trailing: ExperimentBadge(label: l10n.experiments_badge),
      onTap: () => context.push<void>(
        ExperimentsRoutes.experimentLocation(recipeId, experimentId),
      ),
    );
  }
}
