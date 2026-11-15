import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';

/// An in-memory [ExperimentRepository]. The transactional operations record
/// their calls and do the smallest real change, so tests can check both.
class FakeExperimentRepository() implements ExperimentRepository {
  final versions = <RecipeVersionId, RecipeVersion>{};
  final experiments = <ExperimentId, Experiment>{};
  final snapshots = <RecipeVersionId, RecipeSnapshot>{};

  final promoted = <ExperimentId>[];
  final restored = <RecipeVersionId>[];
  final started = <RecipeId>[];

  final _changes = StreamController<void>.broadcast(sync: true);

  void _changed() => _changes.add(null);

  Stream<List<T>> _watch<T>(List<T> Function() read) {
    late final StreamController<List<T>> controller;
    StreamSubscription<void>? subscription;
    controller = StreamController(
      onListen: () {
        controller.add(read());
        subscription = _changes.stream.listen((_) => controller.add(read()));
      },
      // Never return the cancel future: a broadcast subscription's is a
      // root-zone future, which fake-async widget tests never complete.
      onCancel: () {
        unawaited(subscription?.cancel());
      },
    );
    return controller.stream.distinct(listEquals);
  }

  @override
  Stream<List<RecipeVersion>> watchVersions(RecipeId recipeId) => _watch(
    () =>
        versions.values
            .where((version) => version.recipeId == recipeId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );

  @override
  Stream<List<Experiment>> watchExperiments(RecipeId recipeId) => _watch(
    () =>
        experiments.values
            .where((experiment) => experiment.recipeId == recipeId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );

  @override
  Future<RecipeVersion?> getVersion(RecipeVersionId id) async => versions[id];

  @override
  Future<Experiment?> getExperiment(ExperimentId id) async => experiments[id];

  @override
  Future<void> saveVersion(RecipeVersion version) async {
    versions[version.id] = version;
    _changed();
  }

  @override
  Future<void> saveExperiment(Experiment experiment) async {
    experiments[experiment.id] = experiment;
    _changed();
  }

  @override
  Future<void> deleteExperiment(ExperimentId id) async {
    experiments.remove(id);
    _changed();
  }

  @override
  Future<RecipeSnapshot?> getVersionSnapshot(RecipeVersionId id) async =>
      snapshots[id];

  @override
  Future<Experiment> startExperiment(RecipeId recipeId) async {
    started.add(recipeId);
    final n = started.length;
    final experiment = Experiment(
      id: ExperimentId('e$n'),
      recipeId: recipeId,
      baseVersionId: RecipeVersionId('base$n'),
      workingRecipeId: RecipeId('${recipeId.value}-e$n'),
      createdAt: DateTime.utc(2026, 11, 14, n),
    );
    await saveExperiment(experiment);
    return experiment;
  }

  @override
  Future<void> promoteExperiment(ExperimentId id) async {
    promoted.add(id);
    await saveExperiment(
      experiments[id]!.copyWith(outcome: ExperimentOutcome.adopted),
    );
  }

  @override
  Future<void> restoreVersion(RecipeVersionId id) async => restored.add(id);
}

/// Test data builders.
abstract final class HistoryFixtures() {
  static const recipeId = RecipeId('soup');

  static RecipeVersion version(String id, DateTime createdAt) => RecipeVersion(
    id: RecipeVersionId(id),
    recipeId: recipeId,
    createdAt: createdAt,
    snapshotJson: '{}',
    summary: 'Version $id',
  );

  static Experiment experiment(String id, DateTime createdAt) => Experiment(
    id: ExperimentId(id),
    recipeId: recipeId,
    baseVersionId: const RecipeVersionId('base'),
    workingRecipeId: RecipeId('work-$id'),
    createdAt: createdAt,
  );
}
