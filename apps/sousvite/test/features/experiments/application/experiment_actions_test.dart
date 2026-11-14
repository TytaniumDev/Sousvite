import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/experiments/application/experiment_actions.dart';

import '../fakes.dart';

void main() {
  group(ExperimentActions, () {
    late FakeExperimentRepository repository;
    late ExperimentActions actions;

    setUp(() {
      repository = FakeExperimentRepository();
      actions = ProviderContainer.test(
        overrides: [experimentRepositoryProvider.overrideWithValue(repository)],
      ).read(experimentActionsProvider);
    });

    test('starts an experiment through the repository', () async {
      final experiment = await actions.start(HistoryFixtures.recipeId);

      expect(repository.started, [HistoryFixtures.recipeId]);
      expect(repository.experiments[experiment.id], experiment);
    });

    test('records what changed and how it went', () async {
      final experiment = await actions.start(HistoryFixtures.recipeId);

      await actions.describe(experiment, changeDescription: 'Olive oil');
      final described = repository.experiments[experiment.id]!;
      await actions.describe(described, notes: 'Lighter');

      final saved = repository.experiments[experiment.id]!;
      expect(saved.changeDescription, 'Olive oil');
      expect(saved.notes, 'Lighter');
    });

    test('saves nothing when the text is unchanged', () async {
      final experiment = await actions.start(HistoryFixtures.recipeId);
      repository.experiments.clear();

      await actions.describe(experiment, notes: '');

      expect(repository.experiments, isEmpty);
    });

    test('promotes, keeps, and restores', () async {
      final experiment = await actions.start(HistoryFixtures.recipeId);

      await actions.keep(experiment);
      expect(
        repository.experiments[experiment.id]!.outcome,
        ExperimentOutcome.kept,
      );

      await actions.promote(experiment.id);
      expect(repository.promoted, [experiment.id]);

      await actions.restore(const RecipeVersionId('v1'));
      expect(repository.restored, [const RecipeVersionId('v1')]);
    });
  });
}
