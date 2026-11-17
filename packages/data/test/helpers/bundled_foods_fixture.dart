import 'package:sqlite3/sqlite3.dart';

/// The bundled file's tables, as `tools/usda_builder` creates them.
const _schema = '''
CREATE TABLE foods (
  id TEXT NOT NULL PRIMARY KEY,
  source TEXT NOT NULL,
  external_id TEXT NOT NULL,
  name TEXT NOT NULL,
  brand TEXT
);
CREATE TABLE food_nutrients (
  food_id TEXT NOT NULL,
  nutrient_code TEXT NOT NULL,
  amount_per100g REAL NOT NULL,
  PRIMARY KEY (food_id, nutrient_code)
);
CREATE TABLE food_portions (
  id TEXT NOT NULL PRIMARY KEY,
  food_id TEXT NOT NULL,
  amount_numerator INTEGER NOT NULL,
  amount_denominator INTEGER NOT NULL,
  gram_weight REAL NOT NULL,
  unit TEXT,
  description TEXT NOT NULL DEFAULT ''
);
INSERT INTO foods VALUES
  ('usda:1', 'usda', '1', 'Butter, without salt', NULL),
  ('usda:2', 'usda', '2', 'Butter, salted', NULL),
  ('usda:3', 'usda', '3', 'Cookies, butter, commercially prepared', NULL);
INSERT INTO food_nutrients VALUES
  ('usda:1', '208', 717.0),
  ('usda:1', '203', 0.85);
INSERT INTO food_portions VALUES
  ('usda:1:tbsp', 'usda:1', 1, 1, 14.2, 'tablespoon', '1 tbsp'),
  ('usda:1:pat', 'usda:1', 1, 1, 5, NULL, '1 pat');
''';

/// A small bundled file with butter, salted butter, and butter cookies.
///
/// Butter has two nutrients and two portions; the others have none.
Database bundledFoodsFixture() => sqlite3.openInMemory()..execute(_schema);
