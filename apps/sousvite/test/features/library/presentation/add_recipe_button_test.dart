import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/editor/editor.dart';
import 'package:sousvite/features/import/import.dart';
import 'package:sousvite/features/library/presentation/add_recipe_button.dart';

import '../../../helpers/fakes/fake_folder_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../../helpers/helpers.dart';

void main() {
  const breakfast = FolderId('breakfast');
  late FakeFolderRepository folders;
  late GoRouter router;

  setUp(() {
    folders = FakeFolderRepository()
      ..seed(
        Folder(
          id: breakfast,
          name: 'Breakfast',
          createdAt: RecipeFixtures.createdAt,
        ),
      );
  });

  Future<void> pumpButton(WidgetTester tester, FolderId? folderId) async {
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            floatingActionButton: AddRecipeButton(folderId: folderId),
          ),
        ),
        GoRoute(
          path: ImportRoutes.path,
          builder: (_, state) => Text('Import ${state.uri.query}'),
        ),
        GoRoute(
          path: EditorRoutes.path,
          builder: (_, state) => Text('Editor ${state.uri.query}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpRouterApp(
      router,
      overrides: [folderRepositoryProvider.overrideWithValue(folders)],
    );
    await tester.pumpAndSettle();
  }

  group(AddRecipeButton, () {
    testWidgets('in a folder, imports or writes a recipe into it', (
      tester,
    ) async {
      await pumpButton(tester, breakfast);

      await tester.tap(find.byType(AddRecipeButton));
      await tester.pumpAndSettle();
      expect(find.text('Add to which folder?'), findsNothing);
      await tester.tap(find.text('Write a recipe'));
      await tester.pumpAndSettle();
      expect(find.text('Editor folder=breakfast'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AddRecipeButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import from a link'));
      await tester.pumpAndSettle();
      expect(find.text('Import folder=breakfast'), findsOneWidget);
    });

    testWidgets('on the main page, asks which folder first', (tester) async {
      await pumpButton(tester, null);

      await tester.tap(find.byType(AddRecipeButton));
      await tester.pumpAndSettle();
      expect(find.text('Add to which folder?'), findsOneWidget);
      await tester.tap(find.text('Breakfast'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Write a recipe'));
      await tester.pumpAndSettle();
      expect(find.text('Editor folder=breakfast'), findsOneWidget);
    });

    testWidgets('can make a new folder to add to', (tester) async {
      await pumpButton(tester, null);

      await tester.tap(find.byType(AddRecipeButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New folder'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Soups');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Write a recipe'));
      await tester.pumpAndSettle();

      final soups = folders.allFolders.firstWhere((f) => f.name == 'Soups');
      expect(find.text('Editor folder=${soups.id.value}'), findsOneWidget);
    });

    testWidgets('closing the folder question adds nothing', (tester) async {
      await pumpButton(tester, null);

      await tester.tap(find.byType(AddRecipeButton));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Add to which folder?'), findsNothing);
      expect(find.text('Write a recipe'), findsNothing);
    });

    testWidgets('cancelling the new folder name keeps the question open', (
      tester,
    ) async {
      await pumpButton(tester, null);

      await tester.tap(find.byType(AddRecipeButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New folder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Add to which folder?'), findsOneWidget);
      expect(folders.allFolders, hasLength(1));
    });
  });
}
