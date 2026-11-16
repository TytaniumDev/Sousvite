import 'package:data/src/change_log/entity_codec.dart';
import 'package:data/src/change_log/field_values.dart';
import 'package:domain/domain.dart';

/// A food fetched online with its nutrients and portions: what the cache
/// stores and syncs as one entity, so a recipe that uses it works offline
/// on every device.
typedef CachedFood = ({
  Food food,
  List<FoodNutrient> nutrients,
  List<FoodPortion> portions,
});

/// [CachedFood] fields in the change log. Nutrients and portions are one
/// field each, since a refetch replaces them together.
final class CachedFoodCodec() implements EntityCodec<CachedFood> {
  @override
  String get entity => 'cached_food';

  @override
  String idOf(CachedFood value) => value.food.id.value;

  @override
  Map<String, Object?> encode(CachedFood value) => {
    'source': encodeEnum(value.food.source),
    'externalId': value.food.externalId,
    'name': value.food.name,
    'brand': value.food.brand,
    'nutrients': {
      for (final nutrient in value.nutrients)
        nutrient.nutrientCode: nutrient.amountPer100g,
    },
    'portions': [
      for (final portion in value.portions)
        {
          'id': portion.id.value,
          'amount': encodeQuantity(portion.amount),
          'gramWeight': portion.gramWeight,
          'unit': encodeEnum(portion.unit),
          'description': portion.description,
        },
    ],
  };

  @override
  CachedFood? decode(String id, Map<String, Object?> fields) {
    final source = decodeEnum(NutritionSource.values, fields['source']);
    if (source == null) return null;
    if (fields case {
      'externalId': final String externalId,
      'name': final String name,
      'nutrients': final Map<String, Object?> nutrients,
      'portions': final List<Object?> portions,
    }) {
      final foodId = FoodId(id);
      return (
        food: Food(
          id: foodId,
          source: source,
          externalId: externalId,
          name: name,
          brand: fields['brand'] as String?,
        ),
        nutrients: [
          for (final MapEntry(:key, :value) in nutrients.entries)
            if (value is num)
              FoodNutrient(
                foodId: foodId,
                nutrientCode: key,
                amountPer100g: value.toDouble(),
              ),
        ],
        portions: [
          for (final portion in portions)
            if (portion case {
              'id': final String portionId,
              'gramWeight': final num gramWeight,
            })
              if (decodeQuantity(portion['amount']) case final amount?)
                FoodPortion(
                  id: FoodPortionId(portionId),
                  foodId: foodId,
                  amount: amount,
                  gramWeight: gramWeight.toDouble(),
                  unit: decodeEnum(Unit.values, portion['unit']),
                  description: portion['description'] as String? ?? '',
                ),
        ],
      );
    }
    return null;
  }
}

/// [NutritionMatch] fields in the change log.
final class NutritionMatchCodec() implements EntityCodec<NutritionMatch> {
  @override
  String get entity => 'nutrition_match';

  @override
  String idOf(NutritionMatch value) => value.id.value;

  @override
  Map<String, Object?> encode(NutritionMatch value) => {
    'ingredientLineId': value.ingredientLineId.value,
    'foodId': value.foodId.value,
    'source': encodeEnum(value.source),
    'gramWeight': value.gramWeight,
    'userConfirmed': value.userConfirmed,
  };

  @override
  NutritionMatch? decode(String id, Map<String, Object?> fields) {
    final source = decodeEnum(NutritionSource.values, fields['source']);
    if (fields
        case {
          'ingredientLineId': final String lineId,
          'foodId': final String foodId,
          'gramWeight': final num gramWeight,
        }
        when source != null) {
      return NutritionMatch(
        id: NutritionMatchId(id),
        ingredientLineId: IngredientLineId(lineId),
        foodId: FoodId(foodId),
        source: source,
        gramWeight: gramWeight.toDouble(),
        userConfirmed: fields['userConfirmed'] as bool? ?? false,
      );
    }
    return null;
  }
}
