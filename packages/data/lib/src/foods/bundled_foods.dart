import 'package:data/src/foods/food_search.dart';
import 'package:domain/domain.dart';
import 'package:sqlite3/common.dart';
import 'package:typed_data/typed_data.dart';

/// The bundled USDA generic foods: a read-only SQLite file built by
/// `tools/usda_builder`, opened by the app (ENGINEERING.md §11.1).
///
/// It is a separate database rather than an attached one, so replacing the
/// file never needs a migration and the same code runs on every platform:
/// the app opens it from the asset's bytes in an in-memory file system,
/// which works with native SQLite and with SQLite in WebAssembly.
final class BundledFoods(
  /// The open bundled file. Its `foods`, `food_nutrients`, and
  /// `food_portions` tables have the same columns as the Drift ones.
  final CommonDatabase database,
) {
  /// Opens the bundled file from its [bytes] in [sqlite3], read-only.
  factory fromBytes(CommonSqlite3 sqlite3, List<int> bytes) {
    final fileSystem = InMemoryFileSystem(name: 'usda-foods');
    sqlite3.registerVirtualFileSystem(fileSystem);
    fileSystem.fileData['/usda_foods.sqlite'] = Uint8Buffer()..addAll(bytes);
    // The in-memory file system accepts writes even in read-only mode, so
    // the connection itself refuses them.
    return BundledFoods(
      sqlite3.open(
        '/usda_foods.sqlite',
        vfs: fileSystem.name,
        mode: OpenMode.readOnly,
      )..execute('PRAGMA query_only = ON'),
    );
  }

  /// The food with [id], or null when it is not bundled.
  Food? food(FoodId id) {
    final rows = database.select('SELECT * FROM foods WHERE id = ?', [
      id.value,
    ]);
    return rows.isEmpty ? null : _food(rows.single);
  }

  /// The nutrients of [foodId], per 100 g.
  List<FoodNutrient> nutrients(FoodId foodId) => [
    for (final row in database.select(
      'SELECT * FROM food_nutrients WHERE food_id = ? ORDER BY nutrient_code',
      [foodId.value],
    ))
      FoodNutrient(
        foodId: foodId,
        nutrientCode: row['nutrient_code'] as String,
        amountPer100g: (row['amount_per100g'] as num).toDouble(),
      ),
  ];

  /// The household portions of [foodId].
  List<FoodPortion> portions(FoodId foodId) => [
    for (final row in database.select(
      'SELECT * FROM food_portions WHERE food_id = ? ORDER BY id',
      [foodId.value],
    ))
      FoodPortion(
        id: FoodPortionId(row['id'] as String),
        foodId: foodId,
        amount: Quantity(
          row['amount_numerator'] as int,
          row['amount_denominator'] as int,
        ),
        gramWeight: (row['gram_weight'] as num).toDouble(),
        unit: _unit(row['unit'] as String?),
        description: row['description'] as String? ?? '',
      ),
  ];

  /// Every bundled food, in id order.
  List<Food> all() => [
    for (final row in database.select('SELECT * FROM foods ORDER BY id'))
      _food(row),
  ];

  /// Foods whose names hold every word of [words].
  List<Food> search(List<String> words) {
    if (words.isEmpty) return const [];
    return [
      for (final row in database.select(
        'SELECT * FROM foods WHERE ${foodSearchWhere(words)}',
        foodSearchPatterns(words),
      ))
        _food(row),
    ];
  }

  /// Closes the file.
  void close() => database.close();

  static Food _food(Row row) => Food(
    id: FoodId(row['id'] as String),
    source: NutritionSource.usda,
    externalId: row['external_id'] as String,
    name: row['name'] as String,
    brand: row['brand'] as String?,
  );

  static Unit? _unit(String? name) {
    for (final unit in Unit.values) {
      if (unit.name == name) return unit;
    }
    return null;
  }
}
