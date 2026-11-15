import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/experiments/application/history_providers.dart';
import 'package:sousvite/features/experiments/application/history_ref.dart';

import '../fakes.dart';

typedef _F = HistoryFixtures;

void main() {
  late FakeExperimentRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeExperimentRepository();
    container = ProviderContainer.test(
      overrides: [experimentRepositoryProvider.overrideWithValue(repository)],
    );
  });

  group('historyTimeline', () {
    test('merges versions and experiments, newest first', () async {
      await repository.saveVersion(_F.version('v1', DateTime.utc(2026)));
      await repository.saveVersion(_F.version('v2', DateTime.utc(2026, 3)));
      await repository.saveExperiment(
        _F.experiment('e1', DateTime.utc(2026, 2)),
      );
      final timeline = container.listen(
        historyTimelineProvider(_F.recipeId),
        (_, _) {},
      );
      expect(timeline.read(), isA<AsyncLoading<HistoryTimeline>>());

      await pumpEventQueue();

      expect(timeline.read().value!.entries, [
        HistoryRef.version(
          id: const RecipeVersionId('v2'),
          createdAt: DateTime.utc(2026, 3),
        ),
        HistoryRef.experiment(
          id: const ExperimentId('e1'),
          createdAt: DateTime.utc(2026, 2),
        ),
        HistoryRef.version(
          id: const RecipeVersionId('v1'),
          createdAt: DateTime.utc(2026),
        ),
      ]);
    });

    test('reports an error from either list', () async {
      final failing = ProviderContainer.test(
        overrides: [
          experimentRepositoryProvider.overrideWithValue(repository),
          recipeVersionsProvider(_F.recipeId)
              .overrideWith((ref) => Stream.error(StateError('broken'))),
        ],
      );
      final timeline = failing.listen(
        historyTimelineProvider(_F.recipeId),
        (_, _) {},
      );

      await pumpEventQueue();

      expect(timeline.read().error, isA<StateError>());
    });
  });

  group('historyExperiment', () {
    test('picks one experiment and is null once it is gone', () async {
      final experiment = _F.experiment('e1', DateTime.utc(2026));
      await repository.saveExperiment(experiment);
      final provider = historyExperimentProvider(_F.recipeId, experiment.id);
      final subscription = container.listen(provider, (_, _) {});
      await pumpEventQueue();

      expect(subscription.read().value, experiment);

      await repository.deleteExperiment(experiment.id);
      await pumpEventQueue();

      expect(subscription.read().value, isNull);
    });
  });

  group('historyVersion', () {
    test('picks one version', () async {
      final version = _F.version('v1', DateTime.utc(2026));
      await repository.saveVersion(version);
      final provider = historyVersionProvider(_F.recipeId, version.id);
      final subscription = container.listen(provider, (_, _) {});
      await pumpEventQueue();

      expect(subscription.read().value, version);
    });
  });

  group('versionSnapshot', () {
    test('reads the decoded snapshot', () async {
      const id = RecipeVersionId('v1');
      final snapshot = RecipeSnapshot(
        recipe: Recipe(
          id: _F.recipeId,
          title: 'Soup',
          servings: Quantity(4),
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );
      repository.snapshots[id] = snapshot;
      container.listen(versionSnapshotProvider(id), (_, _) {});

      expect(
        await container.read(versionSnapshotProvider(id).future),
        snapshot,
      );
    });
  });
}
