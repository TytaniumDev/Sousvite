import 'package:data/src/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:test/test.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

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
}
