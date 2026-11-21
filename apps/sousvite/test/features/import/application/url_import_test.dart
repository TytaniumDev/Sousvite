import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/application/recipe_importers.dart';
import 'package:sousvite/features/import/application/url_import.dart';
import 'package:sousvite/features/import/data/library_umami_transfer.dart';
import 'package:sousvite/features/import/data/page_url_importer.dart';

import 'package:sousvite/shared/photos/photos.dart';

import '../../../helpers/fakes/fake_folder_repository.dart';
import '../../../helpers/fakes/fake_photo_store.dart';
import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../nutrition/fakes.dart' show FakeFoodRepository, emptyBundledFoods;
import '../fakes.dart';

void main() {
  late FakeUrlImporter importer;
  late FakeRecipeRepository recipes;
  late FakeFoodRepository foods;
  late FakeFolderRepository folders;
  late ProviderContainer container;

  setUp(() {
    importer = FakeUrlImporter();
    recipes = FakeRecipeRepository();
    foods = FakeFoodRepository();
    folders = FakeFolderRepository();
    container = ProviderContainer.test(
      overrides: [
        urlImporterProvider.overrideWithValue(importer),
        recipeRepositoryProvider.overrideWithValue(recipes),
        foodRepositoryProvider.overrideWithValue(foods),
        emptyBundledFoods,
        folderRepositoryProvider.overrideWithValue(folders),
      ],
    )..listen(urlImportProvider, (_, _) {});
  });

  UrlImport notifier() => container.read(urlImportProvider.notifier);

  group('UrlImport', () {
    test('starts empty', () {
      expect(
        container.read(urlImportProvider),
        const AsyncData<RecipeId?>(null),
      );
    });

    test('imports and saves the recipe, then resets', () async {
      importer.result = RecipeSnapshot(
        recipe: RecipeFixtures.recipe(id: 'chili', title: 'Chili'),
      );

      await notifier().import('seriouseats.com/chili');

      expect(importer.requested, [Uri.parse('https://seriouseats.com/chili')]);
      expect(container.read(urlImportProvider).value, const RecipeId('chili'));
      expect(
        (await recipes.getRecipe(const RecipeId('chili')))?.title,
        'Chili',
      );

      notifier().reset();
      expect(container.read(urlImportProvider).value, isNull);
    });

    test('matches ingredients that clearly fit a food', () async {
      const garlic = Food(
        id: FoodId('usda:1'),
        source: NutritionSource.usda,
        externalId: '1',
        name: 'Garlic, raw',
      );
      foods.addFood(garlic);
      importer.result = RecipeSnapshot(
        recipe: RecipeFixtures.recipe(id: 'chili'),
        ingredientLines: [
          RecipeFixtures.line(
            'l1',
            recipeId: 'chili',
            quantity: Quantity(10),
            unit: Unit.gram,
            name: 'garlic',
          ),
        ],
      );

      await notifier().import('seriouseats.com/chili');

      final match = foods.matches.values.single;
      expect(match.ingredientLineId, const IngredientLineId('l1'));
      expect(match.foodId, garlic.id);
      expect(match.gramWeight, 10);
    });

    test('files the recipe into the folder it was added from', () async {
      const soups = FolderId('soups');
      importer.result = RecipeSnapshot(
        recipe: RecipeFixtures.recipe(id: 'chili', title: 'Chili'),
      );

      await notifier().import('seriouseats.com/chili', folderId: soups);

      expect(folders.recipeIdsIn(soups), [const RecipeId('chili')]);
    });

    test('rejects text that is not a link without fetching', () async {
      await notifier().import('chili');

      final error = container.read(urlImportProvider).error;
      expect(error, isA<ImportFailure>());
      expect((error! as ImportFailure).reason, ImportFailureReason.invalidUrl);
      expect(importer.requested, isEmpty);
    });

    test('keeps the importer failure', () async {
      importer.failure = const ImportFailure(.noRecipe, site: 'a.com');

      await notifier().import('a.com/x');

      expect(container.read(urlImportProvider).error, importer.failure);
    });
  });

  group('importers', () {
    test('fetch pages straight from the site off the web', () {
      final container = ProviderContainer.test(
        overrides: [photoStoreProvider.overrideWithValue(FakePhotoStore())],
      );

      expect(container.read(urlImporterProvider), isA<PageUrlImporter>());
    });

    test('move the library through the file picker for Umami', () {
      final container = ProviderContainer.test(
        overrides: [
          recipeRepositoryProvider.overrideWithValue(FakeRecipeRepository()),
          folderRepositoryProvider.overrideWithValue(FakeFolderRepository()),
          photoStoreProvider.overrideWithValue(FakePhotoStore()),
        ],
      );

      expect(
        container.read(umamiTransferProvider),
        isA<LibraryUmamiTransfer>(),
      );
    });

    test('the web stand-in says it is not available', () async {
      await expectLater(
        const UnavailableUrlImporter().importUrl(Uri.parse('https://a.com')),
        throwsA(
          isA<ImportFailure>()
              .having(
                (f) => f.reason,
                'reason',
                ImportFailureReason.notAvailable,
              )
              .having((f) => f.site, 'site', 'a.com'),
        ),
      );
      expect(
        const ImportFailure(.noRecipe, site: 'a.com').toString(),
        contains('noRecipe'),
      );
    });
  });
}
