import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/experiments/experiments.dart';

import '../../../helpers/fakes/recipe_fixtures.dart';
import '../fakes.dart';
import 'pump_history.dart';

typedef _F = HistoryFixtures;

void main() {
  const versionId = RecipeVersionId('v1');
  late FakeExperimentRepository repository;

  void arrange() {
    repository = FakeExperimentRepository();
    repository.snapshots[versionId] = RecipeSnapshot(
      recipe: RecipeFixtures.recipe(id: 'soup', title: 'Tomato soup'),
      ingredientLines: [
        RecipeFixtures.line(
          'l1',
          recipeId: 'soup',
          name: 'tomatoes',
          quantity: Quantity(2),
          unit: Unit.cup,
        ),
        RecipeFixtures.line('l2', recipeId: 'soup', name: 'salt'),
      ],
      steps: [
        const RecipeStep(
          id: RecipeStepId('s1'),
          recipeId: RecipeId('soup'),
          text: 'Simmer the tomatoes.',
          sortKey: SortKey('a'),
        ),
      ],
    );
  }

  group('VersionScreen', () {
    testWidgets('shows the snapshot and restores it', (tester) async {
      arrange();
      await repository.saveVersion(_F.version('v1', DateTime.utc(2026, 5)));
      final router = await pumpHistory(
        tester,
        ExperimentsRoutes.location(_F.recipeId),
        overrides: [experimentRepositoryProvider.overrideWithValue(repository)],
      );
      unawaited(
        router.push(ExperimentsRoutes.versionLocation(_F.recipeId, versionId)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tomato soup'), findsOneWidget);
      expect(find.textContaining('cups'), findsOneWidget);
      expect(find.text('salt'), findsOneWidget);
      expect(find.text('Simmer the tomatoes.'), findsOneWidget);
      expect(find.textContaining('May 1'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Restore this version'), 100);
      await tester.tap(find.text('Restore this version'));
      await tester.pumpAndSettle();

      expect(repository.restored, [versionId]);
      expect(find.text('Version restored'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });
  });
}
