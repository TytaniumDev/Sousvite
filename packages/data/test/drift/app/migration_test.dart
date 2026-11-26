import 'package:data/src/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:test/test.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;
import 'generated/schema_v5.dart' as v5;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('migrates the schema', () {
    const versions = GeneratedHelper.versions;
    for (final (index, fromVersion) in versions.indexed) {
      for (final toVersion in versions.skip(index + 1)) {
        test('from $fromVersion to $toVersion', () async {
          final schema = await verifier.schemaAt(fromVersion);
          final database = AppDatabase(schema.newConnection());
          await verifier.migrateAndValidate(database, toVersion);
          await database.close();
        });
      }
    }
  });

  test('v1 to v2 keeps ingredient lines, with no count word', () async {
    const oldLine = v1.IngredientLinesData(
      id: 'l1',
      recipeId: 'r1',
      rawText: '3 cloves garlic',
      sortKey: 'a0',
      quantityNumerator: 3,
      quantityDenominator: 1,
      name: 'garlic',
    );
    const newLine = v2.IngredientLinesData(
      id: 'l1',
      recipeId: 'r1',
      rawText: '3 cloves garlic',
      sortKey: 'a0',
      quantityNumerator: 3,
      quantityDenominator: 1,
      name: 'garlic',
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDatabase) {
        batch.insert(oldDatabase.ingredientLines, oldLine);
      },
      validateItems: (newDatabase) async {
        expect(await newDatabase.select(newDatabase.ingredientLines).get(), [
          newLine,
        ]);
      },
    );
  });

  test('v2 to v3 keeps grocery items, with no count word', () async {
    const oldItem = v2.GroceryItemsData(
      id: 'g1',
      listId: 'list1',
      name: 'garlic',
      sortKey: 'a0',
      quantityNumerator: 3,
      quantityDenominator: 1,
      checked: 0,
    );
    const newItem = v3.GroceryItemsData(
      id: 'g1',
      listId: 'list1',
      name: 'garlic',
      sortKey: 'a0',
      quantityNumerator: 3,
      quantityDenominator: 1,
      checked: 0,
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDatabase) {
        batch.insert(oldDatabase.groceryItems, oldItem);
      },
      validateItems: (newDatabase) async {
        expect(await newDatabase.select(newDatabase.groceryItems).get(), [
          newItem,
        ]);
      },
    );
  });

  test('v3 to v4 indexes the recipes already saved for search', () async {
    final schema = await verifier.schemaAt(3);
    final old = v3.DatabaseAtV3(schema.newConnection());
    await old
        .into(old.recipes)
        .insert(
          v3.RecipesCompanion.insert(
            id: 'r1',
            title: 'Tomato soup',
            servingsNumerator: 4,
            servingsDenominator: 1,
            createdAt: '2026-11-16T00:00:00.000Z',
            updatedAt: '2026-11-16T00:00:00.000Z',
          ),
        );
    await old
        .into(old.ingredientLines)
        .insert(
          v3.IngredientLinesCompanion.insert(
            id: 'l1',
            recipeId: 'r1',
            rawText: 'a handful of basil',
            sortKey: 'a0',
            name: const Value('basil'),
          ),
        );
    await old.close();

    final database = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(database, 4);

    expect(await database.recipeDao.watchSearch('"basil"*').first, ['r1']);
    expect(await database.recipeDao.watchSearch('"tomato"*').first, ['r1']);
    await database.close();
  });

  test('v4 to v5 keeps grocery items, combining by food', () async {
    const oldItem = v4.GroceryItemsData(
      id: 'g1',
      listId: 'list1',
      name: 'sugar',
      sortKey: 'a0',
      checked: 0,
    );
    const newItem = v5.GroceryItemsData(
      id: 'g1',
      listId: 'list1',
      name: 'sugar',
      sortKey: 'a0',
      checked: 0,
      combinesByFood: 1,
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 4,
      newVersion: 5,
      createOld: v4.DatabaseAtV4.new,
      createNew: v5.DatabaseAtV5.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDatabase) {
        batch.insert(oldDatabase.groceryItems, oldItem);
      },
      validateItems: (newDatabase) async {
        expect(await newDatabase.select(newDatabase.groceryItems).get(), [
          newItem,
        ]);
      },
    );
  });
}
