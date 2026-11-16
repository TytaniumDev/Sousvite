import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/application/recipe_importers.dart';
import 'package:sousvite/features/import/application/url_import.dart';
import 'package:sousvite/features/import/data/page_url_importer.dart';

import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../fakes.dart';

void main() {
  late FakeUrlImporter importer;
  late FakeRecipeRepository recipes;
  late ProviderContainer container;

  setUp(() {
    importer = FakeUrlImporter();
    recipes = FakeRecipeRepository();
    container = ProviderContainer.test(
      overrides: [
        urlImporterProvider.overrideWithValue(importer),
        recipeRepositoryProvider.overrideWithValue(recipes),
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
      final container = ProviderContainer.test();

      expect(container.read(urlImporterProvider), isA<PageUrlImporter>());
    });

    test('stand-ins say they are not available', () async {
      final container = ProviderContainer.test();
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
      final umami = container.read(umamiTransferProvider);
      await expectLater(umami.importLibrary(), throwsA(isA<ImportFailure>()));
      await expectLater(umami.exportLibrary(), throwsA(isA<ImportFailure>()));
      expect(
        const ImportFailure(.noRecipe, site: 'a.com').toString(),
        contains('noRecipe'),
      );
    });
  });
}
