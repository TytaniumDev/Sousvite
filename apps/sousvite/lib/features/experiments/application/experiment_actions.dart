import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';

part 'experiment_actions.g.dart';

/// Changes to a recipe's experiments and history (PRD 7.11). Screens call
/// these from callbacks with `ref.read(experimentActionsProvider)`.
///
/// Starting, promoting, and restoring each save the current recipe as a
/// version first (in the repository), so every one of them can be undone
/// from history.
class const ExperimentActions(final ExperimentRepository _repository) {
  /// Starts an experiment as a copy of [recipeId]'s current version.
  Future<Experiment> start(RecipeId recipeId) =>
      _repository.startExperiment(recipeId);

  /// Records what changed and how it went, on the latest copy of the
  /// experiment so two fields saved one after the other never undo each
  /// other. Saves nothing when neither changed.
  Future<void> describe(
    ExperimentId id, {
    String? changeDescription,
    String? notes,
  }) async {
    final experiment = await _repository.getExperiment(id);
    if (experiment == null) return;
    final updated = experiment.copyWith(
      changeDescription: changeDescription ?? experiment.changeDescription,
      notes: notes ?? experiment.notes,
    );
    if (updated == experiment) return;
    await _repository.saveExperiment(updated);
  }

  /// Makes the experiment the recipe.
  Future<void> promote(ExperimentId id) => _repository.promoteExperiment(id);

  /// Keeps the experiment only as a logged attempt; the recipe stays as it
  /// is.
  Future<void> keep(Experiment experiment) => _repository.saveExperiment(
    experiment.copyWith(outcome: ExperimentOutcome.kept),
  );

  /// Puts the recipe back the way it was at [versionId].
  Future<void> restore(RecipeVersionId versionId) =>
      _repository.restoreVersion(versionId);
}

@riverpod
ExperimentActions experimentActions(Ref ref) =>
    ExperimentActions(ref.watch(experimentRepositoryProvider));
