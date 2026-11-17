import 'package:collection/collection.dart';
import 'package:data/src/app_database.dart';
import 'package:data/src/change_log/change_recorder.dart';
import 'package:data/src/change_log/entity_applier.dart';
import 'package:data/src/change_log/materializing_applier.dart';
import 'package:data/src/daos/food_dao.dart';
import 'package:data/src/foods/bundled_foods.dart';
import 'package:data/src/foods/food_codecs.dart';
import 'package:data/src/foods/food_rows.dart';
import 'package:data/src/foods/food_search.dart';
import 'package:domain/domain.dart';

/// [FoodRepository] over the bundled USDA foods and the local cache of
/// foods fetched online.
///
/// Cached foods and matches sync, so a recipe's nutrition reads the same on
/// every device. Bundled foods never change, so only their ids sync.
final class DriftFoodRepository(
  /// The database the cache, the matches, and the change log live in.
  final AppDatabase database, {

  /// Records each write's changes for sync.
  required final ChangeRecorder recorder,

  /// The bundled USDA foods, or null where they are not loaded (tests).
  final BundledFoods? bundled,
}) implements FoodRepository {
  FoodDao get _dao => database.foodDao;

  static final _foodCodec = CachedFoodCodec();
  static final _matchCodec = NutritionMatchCodec();

  /// Writes remote changes for cached foods and matches, for
  /// `DriftLocalStore`.
  Map<String, EntityApplier> get appliers => {
    _foodCodec.entity: MaterializingApplier(
      database,
      codec: _foodCodec,
      write: _writeFood,
      remove: _dao.deleteFood,
    ),
    _matchCodec.entity: MaterializingApplier(
      database,
      codec: _matchCodec,
      write: (match) async {
        // A line has one match. When two devices matched the same line,
        // the one applied last stays.
        final other = await _dao
            .matchOfLine(match.ingredientLineId.value)
            .getSingleOrNull();
        if (other != null && other.id != match.id.value) {
          await _dao.deleteMatch(other.id);
        }
        await _dao.upsertMatch(match.toCompanion());
      },
      remove: _dao.deleteMatch,
    ),
  };

  @override
  Future<Food?> getFood(FoodId id) async =>
      (await _dao.food(id.value).getSingleOrNull())?.toEntity() ??
      bundled?.food(id);

  @override
  Future<List<FoodNutrient>> getNutrients(FoodId foodId) async {
    final cached = await _dao.nutrientsOf(foodId.value).get();
    if (cached.isNotEmpty) return [for (final row in cached) row.toEntity()];
    return bundled?.nutrients(foodId) ?? const [];
  }

  @override
  Future<List<FoodPortion>> getPortions(FoodId foodId) async {
    if (await _dao.food(foodId.value).getSingleOrNull() != null) {
      return [
        for (final row in await _dao.portionsOf(foodId.value).get())
          row.toEntity(),
      ];
    }
    return bundled?.portions(foodId) ?? const [];
  }

  @override
  Future<List<Food>> searchFoods(String query, {int limit = 20}) async {
    final words = foodSearchWords(query);
    if (words.isEmpty) return const [];
    final cached = [
      for (final row in await _dao.search(words).get()) row.toEntity(),
    ];
    final cachedIds = {for (final food in cached) food.id};
    final foods = [
      ...cached,
      ...?bundled?.search(words).where((food) => !cachedIds.contains(food.id)),
    ];
    return rankFoods(foods, words).take(limit).toList();
  }

  @override
  Future<void> saveFood(
    Food food, {
    required List<FoodNutrient> nutrients,
    required List<FoodPortion> portions,
  }) => recorder.write((changes) async {
    final before = await _cached(food.id.value);
    final cached = (food: food, nutrients: nutrients, portions: portions);
    changes.setChanged(_foodCodec, cached, before: before);
    await _writeFood(cached);
  });

  @override
  Stream<List<NutritionMatch>> watchMatches(RecipeId recipeId) => _dao
      .matchesOf(recipeId.value)
      .watch()
      .map((rows) => [for (final row in rows) row.toEntity()])
      .distinct(const ListEquality<NutritionMatch>().equals);

  @override
  Future<void> saveMatch(NutritionMatch match) =>
      recorder.write((changes) async {
        final other = await _dao
            .matchOfLine(match.ingredientLineId.value)
            .getSingleOrNull();
        if (other != null && other.id != match.id.value) {
          await _dao.deleteMatch(other.id);
          changes.delete(_matchCodec.entity, other.id);
        }
        final before = await _dao.match(match.id.value).getSingleOrNull();
        changes.setChanged(_matchCodec, match, before: before?.toEntity());
        await _dao.upsertMatch(match.toCompanion());
      });

  @override
  Future<void> deleteMatch(NutritionMatchId id) =>
      recorder.write((changes) async {
        await _dao.deleteMatch(id.value);
        changes.delete(_matchCodec.entity, id.value);
      });

  Future<CachedFood?> _cached(String id) async {
    final food = await _dao.food(id).getSingleOrNull();
    if (food == null) return null;
    return (
      food: food.toEntity(),
      nutrients: [
        for (final row in await _dao.nutrientsOf(id).get()) row.toEntity(),
      ],
      portions: [
        for (final row in await _dao.portionsOf(id).get()) row.toEntity(),
      ],
    );
  }

  Future<void> _writeFood(CachedFood cached) => _dao.replaceFood(
    cached.food.toCompanion(),
    nutrients: [
      for (final nutrient in cached.nutrients) nutrient.toCompanion(),
    ],
    portions: [for (final portion in cached.portions) portion.toCompanion()],
  );
}
