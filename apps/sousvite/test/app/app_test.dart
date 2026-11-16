import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/app.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/settings/settings.dart';

import '../features/settings/fakes.dart';
import '../helpers/fakes/fake_folder_repository.dart';
import '../helpers/fakes/fake_recipe_repository.dart';

void main() {
  // The library opens first; fakes keep the real database out of tests.
  final libraryRepositories = [
    recipeRepositoryProvider.overrideWithValue(FakeRecipeRepository()),
    folderRepositoryProvider.overrideWithValue(FakeFolderRepository()),
  ];

  group(SousviteApp, () {
    testWidgets('follows the theme mode setting', (tester) async {
      final container = ProviderContainer.test(
        overrides: [
          appSettingsRepositoryProvider.overrideWithValue(
            FakeAppSettingsRepository(),
          ),
          ...libraryRepositories,
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const SousviteApp(),
        ),
      );
      MaterialApp app() => tester.widget(find.byType(MaterialApp));
      expect(app().themeMode, ThemeMode.system);

      await container
          .read(themeModeControllerProvider.notifier)
          .select(ThemeMode.dark);
      await tester.pump();

      expect(app().themeMode, ThemeMode.dark);
    });

    testWidgets('sets the window title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: libraryRepositories,
          child: const SousviteApp(),
        ),
      );
      await tester.pumpAndSettle();

      final title = tester.widget<Title>(find.byType(Title));
      expect(title.title, 'Sousvite');
    });
  });
}
