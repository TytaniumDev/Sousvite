import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/editor/editor.dart';
import 'package:sousvite/features/editor/presentation/editor_screen.dart';
import 'package:sousvite/features/editor/presentation/ingredients_editor.dart';
import 'package:sousvite/features/editor/presentation/steps_editor.dart';
import 'package:sousvite/features/library/library.dart';
import 'package:sousvite/features/recipe/recipe.dart';

import '../../../helpers/fakes/fake_folder_repository.dart';
import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../../helpers/helpers.dart';

void main() {
  const recipeId = RecipeId('r1');
  const flour = IngredientLineId('flour');
  late FakeRecipeRepository recipes;
  final folders = FakeFolderRepository();

  setUp(() {
    recipes = FakeRecipeRepository()
      ..seed(
        recipe: RecipeFixtures.recipe().copyWith(sourceName: 'Grandma'),
        ingredientSections: [
          RecipeFixtures.ingredientSection('sauce', name: 'Sauce'),
        ],
        lines: [
          RecipeFixtures.line('flour', sortKey: 'a', name: 'flour'),
          RecipeFixtures.line('milk', sortKey: 'b', name: 'milk'),
          RecipeFixtures.line('salt', sectionId: 'sauce', name: 'salt'),
        ],
        stepSections: [
          RecipeFixtures.stepSection('prep', sortKey: 'a', name: 'Prep'),
          RecipeFixtures.stepSection('cook', sortKey: 'b', name: 'Cook'),
        ],
        steps: [RecipeFixtures.step('mix', sectionId: 'prep', text: 'Mix it.')],
      );
  });

  /// Opens the editor on top of a list screen, so Save and Back pop to it.
  Future<GoRouter> pumpEditor(
    WidgetTester tester, {
    RecipeId id = recipeId,
    String? location,
  }) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: LibraryRoutes.path,
      routes: [
        GoRoute(
          path: LibraryRoutes.path,
          builder: (_, _) => const Scaffold(body: Text('Library')),
        ),
        GoRoute(
          path: RecipeRoutes.path,
          builder: (_, state) => Text('Recipe ${state.pathParameters.values}'),
        ),
        ...EditorRoutes.routes,
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpRouterApp(
      router,
      overrides: [
        recipeRepositoryProvider.overrideWithValue(recipes),
        folderRepositoryProvider.overrideWithValue(folders),
      ],
    );
    unawaited(router.push(location ?? EditorRoutes.location(id)));
    await tester.pumpAndSettle();
    return router;
  }

  Finder field(String label) => find.widgetWithText(TextField, label);

  Finder lineField(IngredientLineId id) => find.descendant(
    of: find.byKey(ValueKey(id)),
    matching: find.byType(TextField),
  );

  group(EditorScreen, () {
    testWidgets('shows the recipe and its import note', (tester) async {
      await pumpEditor(tester);

      expect(find.text('Edit recipe'), findsOneWidget);
      expect(find.textContaining('Imported from Grandma'), findsOneWidget);
      expect(find.byType(IngredientLineEditor), findsNWidgets(3));
      expect(find.byType(StepEditor), findsOneWidget);
      expect(find.text('Mix it.'), findsOneWidget);
    });

    testWidgets('saves edits and goes back', (tester) async {
      await pumpEditor(tester);

      await tester.enterText(field('Recipe name'), 'Crepes');
      await tester.enterText(field('Servings'), '2');
      await tester.enterText(field('Total time in minutes'), '30');
      await tester.enterText(field('Notes'), 'Rest the batter.');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Library'), findsOneWidget);
      final saved = recipes.recipeById(recipeId)!;
      expect(saved.title, 'Crepes');
      expect(saved.servings, Quantity(2));
      expect(saved.totalTime, const Duration(minutes: 30));
      expect(saved.notes, 'Rest the batter.');
    });

    testWidgets('a new recipe needs a name, then opens the recipe', (
      tester,
    ) async {
      const id = RecipeId('new');
      final router = await pumpEditor(tester, id: id);
      expect(find.text('New recipe'), findsOneWidget);
      router.go(EditorRoutes.location(id));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('Give the recipe a name first'), findsOneWidget);

      await tester.enterText(field('Recipe name'), 'Soup');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Recipe (new)'), findsOneWidget);
      expect(recipes.recipeById(id)?.title, 'Soup');
    });

    testWidgets('saves a new recipe into the folder it was added from', (
      tester,
    ) async {
      const soups = FolderId('soups');
      final location = EditorRoutes.newRecipeLocation(folderId: soups);
      expect(Uri.parse(location).queryParameters, {'folder': 'soups'});
      expect(Uri.parse(EditorRoutes.newRecipeLocation()).hasQuery, isFalse);
      await pumpEditor(tester, location: location);

      await tester.enterText(field('Recipe name'), 'Soup');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(folders.recipeIdsIn(soups), hasLength(1));
    });

    testWidgets('typing in a line rebuilds only that line', (tester) async {
      await pumpEditor(tester);
      final builds = BuildCounter.start();

      await tester.enterText(lineField(flour), '2 cups rye flour');
      await tester.pump();

      expect(builds.of<IngredientLineEditor>(), 0);
      expect(builds.of<StepEditor>(), 0);
      expect(find.text('2 cups rye flour'), findsWidgets);
    });

    testWidgets('a paste splits into lines and Enter adds one', (tester) async {
      await pumpEditor(tester);

      await tester.enterText(lineField(flour), 'flour\neggs\n\nbutter');
      await tester.pumpAndSettle();
      expect(find.byType(IngredientLineEditor), findsNWidgets(5));

      await tester.enterText(lineField(flour), 'flour\n');
      await tester.pumpAndSettle();
      expect(find.byType(IngredientLineEditor), findsNWidgets(6));
    });

    testWidgets('adds and removes lines, sections, and steps', (tester) async {
      await pumpEditor(tester);

      await tester.tap(find.text('Add ingredient').first);
      await tester.pumpAndSettle();
      expect(find.byType(IngredientLineEditor), findsNWidgets(4));
      await tester.tap(find.byTooltip('Remove ingredient').first);
      await tester.pumpAndSettle();
      expect(find.byType(IngredientLineEditor), findsNWidgets(3));

      await tester.tap(find.text('Add section').first);
      await tester.pumpAndSettle();
      await tester.enterText(field('Section name').at(1), 'Glaze');
      await tester.tap(find.byTooltip('Remove section').first);
      await tester.pumpAndSettle();
      expect(find.text('Sauce'), findsNothing);

      await tester.tap(find.text('Add step').at(1));
      await tester.pumpAndSettle();
      expect(find.byType(StepEditor), findsNWidgets(2));
      await tester.enterText(
        find.descendant(
          of: find.byType(StepEditor).last,
          matching: find.byType(TextField),
        ),
        'Cook it.',
      );
      await tester.tap(find.byTooltip('Remove step').first);
      await tester.pumpAndSettle();
      expect(find.text('Mix it.'), findsNothing);

      await tester.tap(find.text('Add section').last);
      await tester.pumpAndSettle();
      await tester.enterText(field('Section name').last, 'Rest');
      await tester.tap(find.byTooltip('Remove section').last);
      await tester.pumpAndSettle();
      expect(find.text('Rest'), findsNothing);
    });

    testWidgets('dragging a step section reorders it', (tester) async {
      await pumpEditor(tester);

      final handle = find.byIcon(Symbols.drag_indicator_rounded).last;
      await tester.timedDrag(
        handle,
        const Offset(0, -300),
        const Duration(milliseconds: 500),
      );
      await tester.pumpAndSettle();

      final names = tester
          .widgetList<TextField>(field('Section name'))
          .map((f) => f.controller?.text);
      expect(names.skip(1), ['Cook', 'Prep']);
    });

    testWidgets('asks before discarding changes', (tester) async {
      await pumpEditor(tester);
      await tester.enterText(field('Recipe name'), 'Crepes');
      await tester.pump();

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      await navigator.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);

      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.byType(EditorScreen), findsOneWidget);

      await navigator.maybePop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.text('Library'), findsOneWidget);
      expect(recipes.recipeById(recipeId)?.title, 'Oat pancakes');
    });

    testWidgets('duplicates the recipe', (tester) async {
      await pumpEditor(tester);

      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Duplicate'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(field('Recipe name')).controller?.text,
        'Oat pancakes (copy)',
      );
    });

    testWidgets('deletes the recipe with Undo', (tester) async {
      await pumpEditor(tester);

      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete recipe'));
      await tester.pumpAndSettle();
      expect(find.text('Library'), findsOneWidget);
      expect(recipes.recipeById(recipeId), isNull);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(recipes.recipeById(recipeId), isNotNull);
    });

    testWidgets('a new recipe has no menu', (tester) async {
      await pumpEditor(tester, id: const RecipeId('new'));
      expect(find.byTooltip('More options'), findsNothing);
    });
  });
}
