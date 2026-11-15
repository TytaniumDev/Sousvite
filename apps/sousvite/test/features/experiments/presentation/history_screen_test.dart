import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/experiments/experiments.dart';

import '../../../helpers/helpers.dart';
import '../fakes.dart';
import 'pump_history.dart';

typedef _F = HistoryFixtures;

void main() {
  late FakeExperimentRepository repository;

  // Made inside each test so its streams run in the fake-async zone.
  void arrange() => repository = FakeExperimentRepository();

  Future<void> pump(WidgetTester tester) => pumpHistory(
    tester,
    ExperimentsRoutes.location(_F.recipeId),
    overrides: [experimentRepositoryProvider.overrideWithValue(repository)],
  );

  group('HistoryScreen', () {
    testWidgets('shows an empty state', (tester) async {
      arrange();
      await pump(tester);

      expect(find.text('History'), findsOneWidget);
      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('shows an error with a retry', (tester) async {
      arrange();
      await pumpHistory(
        tester,
        ExperimentsRoutes.location(_F.recipeId),
        overrides: [
          experimentRepositoryProvider.overrideWithValue(_FailingRepository()),
        ],
      );

      expect(find.byType(ErrorState), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorState), findsOneWidget);
    });

    testWidgets('lists versions and experiments, newest first', (tester) async {
      arrange();
      await repository.saveVersion(_F.version('v1', DateTime.utc(2026)));
      await repository.saveVersion(
        _F.version('v2', DateTime.utc(2026, 3)).copyWith(summary: ''),
      );
      await repository.saveExperiment(
        _F
            .experiment('e1', DateTime.utc(2026, 2))
            .copyWith(
              changeDescription: 'Olive oil',
              outcome: ExperimentOutcome.kept,
            ),
      );
      await repository.saveExperiment(
        _F.experiment('e2', DateTime.utc(2026, 4)),
      );
      await pump(tester);

      final titles = [
        'Untitled experiment',
        'Saved version',
        'Olive oil',
        'Version v1',
      ];
      final tops = [
        for (final title in titles) tester.getTopLeft(find.text(title)).dy,
      ];
      expect(tops, orderedEquals([...tops]..sort()));
      expect(find.textContaining('Kept as an experiment'), findsOneWidget);
      expect(find.textContaining('In progress'), findsOneWidget);
      expect(find.byType(ExperimentBadge), findsNWidgets(2));
    });

    testWidgets('editing an experiment rebuilds only its tile', (tester) async {
      arrange();
      final experiment = _F.experiment('e1', DateTime.utc(2026, 2));
      await repository.saveExperiment(experiment);
      await repository.saveVersion(_F.version('v1', DateTime.utc(2026)));
      final builds = BuildCounter.start();
      await pump(tester);
      builds.reset();

      await repository.saveExperiment(
        experiment.copyWith(changeDescription: 'Less sugar'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Less sugar'), findsOneWidget);
      expect(builds.ofKey(const ValueKey(ExperimentId('e1'))), 1);
      expect(builds.ofKey(const ValueKey(RecipeVersionId('v1'))), 0);
    });

    testWidgets('starts an experiment and opens it', (tester) async {
      arrange();
      await pump(tester);

      await tester.tap(find.text('Start an experiment'));
      await tester.pumpAndSettle();

      expect(repository.started, [_F.recipeId]);
      expect(find.text('What changed'), findsOneWidget);
    });

    testWidgets('opens a version and an experiment', (tester) async {
      arrange();
      await repository.saveVersion(_F.version('v1', DateTime.utc(2026)));
      await repository.saveExperiment(
        _F.experiment('e1', DateTime.utc(2026, 2)),
      );
      await pump(tester);

      await tester.tap(find.text('Version v1'));
      await tester.pumpAndSettle();
      expect(find.text('This version no longer exists.'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Untitled experiment'));
      await tester.pumpAndSettle();
      expect(find.text('How it went'), findsOneWidget);
    });
  });
}

class _FailingRepository() extends FakeExperimentRepository {
  @override
  Stream<List<RecipeVersion>> watchVersions(RecipeId recipeId) =>
      Stream.error(StateError('broken'));
}
