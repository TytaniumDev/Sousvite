import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/experiments/experiments.dart';

import '../fakes.dart';
import 'pump_history.dart';

typedef _F = HistoryFixtures;

void main() {
  late FakeExperimentRepository repository;
  late Experiment experiment;

  Future<GoRouter> pump(WidgetTester tester, {bool fromHistory = true}) async {
    final router = await pumpHistory(
      tester,
      ExperimentsRoutes.location(_F.recipeId),
      overrides: [experimentRepositoryProvider.overrideWithValue(repository)],
    );
    if (fromHistory) {
      unawaited(
        router.push(
          ExperimentsRoutes.experimentLocation(_F.recipeId, experiment.id),
        ),
      );
      await tester.pumpAndSettle();
    }
    return router;
  }

  // Made inside each test so its streams run in the fake-async zone.
  Future<void> arrange({
    ExperimentOutcome outcome = ExperimentOutcome.open,
  }) async {
    repository = FakeExperimentRepository();
    experiment = _F
        .experiment('e1', DateTime.utc(2026))
        .copyWith(changeDescription: 'Olive oil', outcome: outcome);
    await repository.saveExperiment(experiment);
  }

  group('ExperimentScreen', () {
    testWidgets('shows what changed and saves edits when done', (tester) async {
      await arrange();
      await pump(tester);

      expect(find.text('Olive oil'), findsOneWidget);
      expect(find.text('In progress'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'How it went'),
        'Lighter',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'What changed'),
        'Olive oil, less salt',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final saved = repository.experiments[experiment.id]!;
      expect(saved.notes, 'Lighter');
      expect(saved.changeDescription, 'Olive oil, less salt');
    });

    testWidgets('saves unsaved text when the screen closes', (tester) async {
      await arrange();
      final router = await pump(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'How it went'),
        'Too salty',
      );
      router.pop();
      await tester.pumpAndSettle();

      expect(repository.experiments[experiment.id]!.notes, 'Too salty');
    });

    testWidgets('makes the experiment the recipe', (tester) async {
      await arrange();
      await pump(tester);

      await tester.tap(find.text('Make this the recipe'));
      await tester.pumpAndSettle();

      expect(repository.promoted, [experiment.id]);
      expect(find.text('This is now the recipe'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('keeps it as an experiment', (tester) async {
      await arrange();
      await pump(tester);

      await tester.tap(find.text('Keep as an experiment'));
      await tester.pumpAndSettle();

      expect(
        repository.experiments[experiment.id]!.outcome,
        ExperimentOutcome.kept,
      );
    });

    testWidgets('hides the decision once made', (tester) async {
      await arrange(outcome: ExperimentOutcome.adopted);
      await pump(tester);

      expect(find.text('Made the recipe'), findsOneWidget);
      expect(find.text('Make this the recipe'), findsNothing);
    });

    testWidgets('edits and cooks the working copy', (tester) async {
      await arrange();
      final router = await pump(tester);

      await tester.tap(find.text('Edit the experiment'));
      await tester.pumpAndSettle();
      expect(find.text('/editor/work-e1'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cook it'));
      await tester.pumpAndSettle();
      expect(find.text('/cook/work-e1'), findsOneWidget);
    });

    testWidgets('says so when the experiment is gone', (tester) async {
      await arrange();
      await repository.deleteExperiment(experiment.id);
      await pump(tester);

      expect(find.text('This experiment no longer exists.'), findsOneWidget);
    });
  });
}
