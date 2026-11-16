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
}
