import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/application/recipe_importers.dart';
import 'package:sousvite/features/import/application/umami_progress.dart';
import 'package:sousvite/features/import/import.dart';
import 'package:sousvite/features/import/presentation/umami_section.dart';
import 'package:sousvite/features/library/library.dart';
import 'package:sousvite/l10n/l10n.dart';

import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../../helpers/helpers.dart';
import '../fakes.dart';

void main() {
  late FakeUrlImporter importer;
  late FakeUmamiTransfer umami;

  // Made inside each test so their futures run in the fake-async zone.
  Future<void> pump(
    WidgetTester tester, {
    String initialLocation = ImportRoutes.path,
    RecipeSnapshot? result,
    int? umamiCount,
  }) async {
    importer = FakeUrlImporter()..result = result;
    umami = FakeUmamiTransfer()..outcome = () => umamiCount;
    final router = GoRouter(
      initialLocation: initialLocation,
      redirect: ImportRoutes.redirect,
      routes: [
        ...ImportRoutes.routes,
        GoRoute(
          path: LibraryRoutes.path,
          builder: (context, state) => const Scaffold(body: Text('Library')),
        ),
        GoRoute(
          path: '/editor/:recipeId',
          builder: (context, state) => Scaffold(body: Text(state.uri.path)),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          urlImporterProvider.overrideWithValue(importer),
          umamiTransferProvider.overrideWithValue(umami),
          recipeRepositoryProvider.overrideWithValue(FakeRecipeRepository()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> importLink(WidgetTester tester, String link) async {
    await tester.enterText(find.byType(TextField), link);
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();
  }

  group('ImportScreen', () {
    testWidgets('imports a link and opens it in the editor', (tester) async {
      await pump(tester);
      importer
        ..result = RecipeSnapshot(recipe: RecipeFixtures.recipe(id: 'chili'))
        ..gate = Completer();

      final builds = BuildCounter.start();
      await tester.enterText(find.byType(TextField), 'a.com/chili');
      await tester.testTextInput.receiveAction(TextInputAction.go);
      await tester.pump();
      expect(find.text('Getting the recipe…'), findsOneWidget);
      expect(builds.of<UmamiSection>(), 0);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );

      importer.gate!.complete();
      await tester.pumpAndSettle();

      expect(find.text('/editor/chili'), findsOneWidget);
    });

    testWidgets('imports a link shared from another app', (tester) async {
      await pump(
        tester,
        initialLocation: ImportRoutes.sharedLocation(
          'Best chili https://a.com/chili?x=1+2',
        ),
        result: RecipeSnapshot(recipe: RecipeFixtures.recipe(id: 'chili')),
      );

      expect(importer.requested, [Uri.parse('https://a.com/chili?x=1+2')]);
      expect(find.text('/editor/chili'), findsOneWidget);
    });

    testWidgets('closes to the library when opened from the share sheet', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Library'), findsOneWidget);
    });

    testWidgets('says why a link failed', (tester) async {
      await pump(tester);

      await importLink(tester, 'chili');
      expect(find.textContaining("doesn't look like a link"), findsOneWidget);

      importer.failure = const ImportFailure(.noRecipe, site: 'a.com');
      await importLink(tester, 'a.com/x');
      expect(
        find.text(
          "Couldn't find a recipe on a.com. You can add it by hand instead.",
        ),
        findsOneWidget,
      );

      importer.failure = const ImportFailure(.unreachable);
      await importLink(tester, 'a.com/x');
      expect(find.textContaining("Couldn't reach this site"), findsOneWidget);

      importer.failure = const ImportFailure(.notAvailable);
      await importLink(tester, 'a.com/x');
      expect(find.text("This kind of import isn't ready yet."), findsOneWidget);

      importer.failure = const FormatException('bug');
      await importLink(tester, 'a.com/x');
      expect(find.textContaining('Something went wrong'), findsOneWidget);
    });

    testWidgets('imports an Umami library', (tester) async {
      await pump(tester);
      umami
        ..outcome = (() => 12)
        ..gate = Completer();

      await tester.tap(find.text('Import from Umami'));
      await tester.pump();
      expect(find.text('Importing…'), findsOneWidget);
      await tester.tap(find.text('Export for Umami'));

      umami.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Imported 12 recipes'), findsOneWidget);
    });

    testWidgets('shows the import progress in a dialog until it ends', (
      tester,
    ) async {
      await pump(tester);
      umami
        ..outcome = (() => 10)
        ..progress = const [
          UmamiImportProgress(UmamiImportStage.reading),
          UmamiImportProgress(UmamiImportStage.recipes, done: 3, total: 10),
        ]
        ..gate = Completer();

      await tester.tap(find.text('Import from Umami'));
      await tester.pumpAndSettle();
      expect(find.text('Importing from Umami'), findsOneWidget);
      expect(find.text('Saving recipes: 3 of 10'), findsOneWidget);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        0.3,
      );

      // The dialog can't be dismissed while the import runs.
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      expect(find.text('Importing from Umami'), findsOneWidget);

      umami.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Importing from Umami'), findsNothing);
      expect(find.text('Imported 10 recipes'), findsOneWidget);
      expect(find.text('Import recipe'), findsOneWidget);
    });

    testWidgets('closes the dialog when the import ends right away', (
      tester,
    ) async {
      await pump(tester);
      umami
        ..outcome = (() => 1)
        ..progress = const [
          UmamiImportProgress(UmamiImportStage.photos, done: 1, total: 2),
        ];

      await tester.tap(find.text('Import from Umami'));
      await tester.pumpAndSettle();

      expect(find.text('Importing from Umami'), findsNothing);
      expect(find.text('Import recipe'), findsOneWidget);
    });

    testWidgets('imports an Umami export shared from another app', (
      tester,
    ) async {
      await pump(
        tester,
        initialLocation: ImportRoutes.archiveLocation('/cache/Umami.zip'),
        umamiCount: 3,
      );

      expect(umami.sharedArchives, ['/cache/Umami.zip']);
      expect(find.text('Imported 3 recipes'), findsOneWidget);
    });

    testWidgets('sends a zip file opened in the app to the import', (
      tester,
    ) async {
      await pump(tester, initialLocation: '/private/Inbox/Umami%20Export.ZIP');

      expect(find.byType(UmamiSection), findsOneWidget);
      expect(umami.sharedArchives, ['/private/Inbox/Umami Export.ZIP']);
    });

    testWidgets('exports for Umami', (tester) async {
      await pump(tester);
      umami
        ..outcome = (() => 1)
        ..gate = Completer();

      await tester.tap(find.text('Export for Umami'));
      await tester.pump();
      expect(find.text('Exporting…'), findsOneWidget);

      umami.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Exported 1 recipe'), findsOneWidget);
    });

    testWidgets('reports an Umami failure and says nothing on cancel', (
      tester,
    ) async {
      await pump(tester);

      umami.outcome = () => throw const ImportFailure(.invalidFile);
      await tester.tap(find.text('Import from Umami'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining("That file isn't an Umami HTML export."),
        findsOneWidget,
      );

      ScaffoldMessenger.of(tester.element(find.byType(ListView)))
          .removeCurrentSnackBar();
      umami.outcome = () => null;
      await tester.tap(find.text('Import from Umami'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
