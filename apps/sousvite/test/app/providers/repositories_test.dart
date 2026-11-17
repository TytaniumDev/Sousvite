import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/database.dart';
import 'package:sousvite/app/providers/repositories.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));

  tearDown(() => database.close());

  ProviderContainer container() {
    final created = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(created.dispose);
    return created;
  }

  group('changeRecorderProvider', () {
    test('records writes in the private space with one device id', () async {
      final recorder = await container().read(changeRecorderProvider.future);
      final again = await container().read(changeRecorderProvider.future);

      expect(recorder.spaceId, privateSpaceId);
      expect(recorder.clock.nodeId, isNotEmpty);
      expect(again.clock.nodeId, recorder.clock.nodeId);
    });
  });

  group('recipeRepositoryProvider', () {
    test('saves recipes to the database once the recorder loads', () async {
      final providers = container();
      await providers.read(changeRecorderProvider.future);
      final repository = providers.read(recipeRepositoryProvider);
      final recipe = Recipe(
        id: const RecipeId('r1'),
        title: 'Soup',
        servings: Quantity(2),
        createdAt: DateTime.utc(2026, 11, 16),
        updatedAt: DateTime.utc(2026, 11, 16),
      );

      await repository.saveRecipe(recipe);

      expect(repository, isA<DriftRecipeRepository>());
      expect(await repository.getRecipe(recipe.id), recipe);
      expect(await database.syncDao.changesAfter(null), isNotEmpty);
    });
  });

  group('recipeSpaceRepositoryProvider', () {
    test('reads recipe spaces from the database', () async {
      final providers = container();
      await providers.read(changeRecorderProvider.future);
      final repository = providers.read(recipeSpaceRepositoryProvider);

      expect(repository, isA<DriftRecipeSpaceRepository>());
      expect(await repository.sharedSpaceOf(const RecipeId('r1')), isNull);
    });
  });

  group('folderRepositoryProvider', () {
    test('saves folders to the database once the recorder loads', () async {
      final providers = container();
      await providers.read(changeRecorderProvider.future);
      final repository = providers.read(folderRepositoryProvider);
      final folder = Folder(
        id: const FolderId('f1'),
        name: 'Soups',
        createdAt: DateTime.utc(2026, 11, 16),
      );

      await repository.saveFolder(folder);

      expect(repository, isA<DriftFolderRepository>());
      expect(await repository.getFolder(folder.id), folder);
    });
  });

  group('groceryRepositoryProvider', () {
    test('saves lists to the database once the recorder loads', () async {
      final providers = container();
      await providers.read(changeRecorderProvider.future);
      final repository = providers.read(groceryRepositoryProvider);
      final list = GroceryList(
        id: const GroceryListId('g1'),
        name: 'Weekly',
        createdAt: DateTime.utc(2026, 11, 16),
      );

      await repository.saveList(list);

      expect(repository, isA<DriftGroceryRepository>());
      expect(await repository.watchLists().first, [list]);
    });
  });

  group('experimentRepositoryProvider', () {
    test('starts experiments on saved recipes', () async {
      final providers = container();
      await providers.read(changeRecorderProvider.future);
      final recipe = Recipe(
        id: const RecipeId('r1'),
        title: 'Soup',
        servings: Quantity(2),
        createdAt: DateTime.utc(2026, 11, 16),
        updatedAt: DateTime.utc(2026, 11, 16),
      );
      await providers.read(recipeRepositoryProvider).saveRecipe(recipe);
      final repository = providers.read(experimentRepositoryProvider);

      final experiment = await repository.startExperiment(recipe.id);

      expect(repository, isA<DriftExperimentRepository>());
      expect(await repository.watchExperiments(recipe.id).first, [experiment]);
    });
  });

  group('settings repositories', () {
    test('save settings, tools, and prefs to the database', () async {
      final providers = container();
      await providers.read(changeRecorderProvider.future);
      final settings = providers.read(appSettingsRepositoryProvider);
      final tools = providers.read(measuringToolRepositoryProvider);
      final prefs = providers.read(userRecipePrefsRepositoryProvider);
      final tool = MeasuringTool(
        id: const MeasuringToolId('c1'),
        capacity: Quantity(1),
        unit: Unit.cup,
      );
      final recipePrefs = UserRecipePrefs(
        recipeId: const RecipeId('r1'),
        servings: Quantity(2),
      );

      await settings.saveSettings(const AppSettings(theme: .dark));
      await tools.saveTool(tool);
      await prefs.savePrefs(recipePrefs);

      expect(
        await settings.watchSettings().first,
        const AppSettings(theme: ThemePreference.dark),
      );
      expect(await tools.watchTools().first, [tool]);
      expect(await prefs.watchPrefs(recipePrefs.recipeId).first, recipePrefs);
    });
  });
}
