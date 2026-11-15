import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/experiments/application/history_ref.dart';

part 'history_providers.g.dart';

/// A recipe's past versions, newest first.
@riverpod
Stream<List<RecipeVersion>> recipeVersions(Ref ref, RecipeId recipeId) =>
    ref.watch(experimentRepositoryProvider).watchVersions(recipeId);

/// A recipe's experiments, newest first.
@riverpod
Stream<List<Experiment>> recipeExperiments(Ref ref, RecipeId recipeId) =>
    ref.watch(experimentRepositoryProvider).watchExperiments(recipeId);

/// Versions and experiments together, newest first.
@riverpod
AsyncValue<HistoryTimeline> historyTimeline(Ref ref, RecipeId recipeId) {
  final versions = ref.watch(recipeVersionsProvider(recipeId));
  final experiments = ref.watch(recipeExperimentsProvider(recipeId));
  return switch ((versions, experiments)) {
    (AsyncError(:final error, :final stackTrace), _) ||
    (
      _,
      AsyncError(:final error, :final stackTrace),
    ) => AsyncError(error, stackTrace),
    (AsyncData(value: final versions), AsyncData(value: final experiments)) =>
      AsyncData(
        HistoryTimeline(
          entries: [
            for (final version in versions)
              HistoryRef.version(id: version.id, createdAt: version.createdAt),
            for (final experiment in experiments)
              HistoryRef.experiment(
                id: experiment.id,
                createdAt: experiment.createdAt,
              ),
          ]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        ),
      ),
    _ => const AsyncLoading(),
  };
}

/// One experiment of [recipeId], or null once it is deleted.
@riverpod
AsyncValue<Experiment?> historyExperiment(
  Ref ref,
  RecipeId recipeId,
  ExperimentId experimentId,
) => ref
    .watch(recipeExperimentsProvider(recipeId))
    .whenData(
      (experiments) => experiments
          .where((experiment) => experiment.id == experimentId)
          .firstOrNull,
    );

/// One past version of [recipeId], or null once it is gone.
@riverpod
AsyncValue<RecipeVersion?> historyVersion(
  Ref ref,
  RecipeId recipeId,
  RecipeVersionId versionId,
) => ref
    .watch(recipeVersionsProvider(recipeId))
    .whenData(
      (versions) =>
          versions.where((version) => version.id == versionId).firstOrNull,
    );

/// What the recipe looked like at version [versionId].
@riverpod
Future<RecipeSnapshot?> versionSnapshot(Ref ref, RecipeVersionId versionId) =>
    ref.watch(experimentRepositoryProvider).getVersionSnapshot(versionId);
