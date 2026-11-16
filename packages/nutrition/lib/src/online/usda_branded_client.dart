import 'package:domain/domain.dart';
import 'package:nutrition/src/online/fetched_food.dart';
import 'package:nutrition/src/online/serving_text.dart';

/// Calls the `usdaProxy` function with a request such as
/// `{action: 'search', query: 'oat milk'}` and returns FoodData Central's
/// JSON, decoded (ENGINEERING.md §11.1).
typedef UsdaProxyCall = Future<Object?> Function(Map<String, Object?> request);

/// Searches USDA Branded Foods through our proxy, which holds the API key.
final class UsdaBrandedClient(
  /// Sends a request to the proxy.
  final UsdaProxyCall _call, {

  /// Results per search. The proxy allows at most 50.
  final int pageSize = 20,
}) {
  /// Branded foods matching [query], with nutrients per 100 g.
  Future<List<FetchedFood>> search(String query) async => parseUsdaSearch(
    await _call({'action': 'search', 'query': query, 'pageSize': pageSize}),
  );

  /// The branded food whose UPC is [barcode], or null.
  Future<FetchedFood?> lookupBarcode(String barcode) async {
    final digits = barcode.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    final response = await _call({'action': 'search', 'query': digits});
    return parseUsdaSearch(response, gtin: digits).firstOrNull;
  }
}

/// The foods in a FoodData Central `/foods/search` response, or only the
/// one whose `gtinUpc` is [gtin]. Malformed entries are skipped.
List<FetchedFood> parseUsdaSearch(Object? response, {String? gtin}) {
  if (response is! Map || response['foods'] is! List) return const [];
  return [
    for (final food in response['foods'] as List)
      if (food is Map<String, Object?> &&
          (gtin == null || _sameGtin(food['gtinUpc'], gtin)))
        ?_food(food),
  ];
}

bool _sameGtin(Object? value, String gtin) =>
    value is String &&
    value.replaceFirst(RegExp('^0+'), '') ==
        gtin.replaceFirst(RegExp('^0+'), '');

FetchedFood? _food(Map<String, Object?> json) {
  final fdcId = json['fdcId'];
  final description = json['description'];
  if (fdcId is! int || description is! String) return null;
  final id = FoodId('usda:$fdcId');
  final brand = json['brandName'] ?? json['brandOwner'];
  return (
    food: Food(
      id: id,
      source: .usda,
      externalId: '$fdcId',
      name: description,
      brand: brand is String && brand.isNotEmpty ? brand : null,
    ),
    nutrients: [
      for (final nutrient in json['foodNutrients'] as List? ?? const [])
        if (nutrient case {
          'nutrientNumber': final String code,
          'value': final num value,
        })
          FoodNutrient(
            foodId: id,
            nutrientCode: code,
            amountPer100g: value.toDouble(),
          ),
    ],
    portions: [?_serving(id, json)],
  );
}

/// The label serving, when it is in grams: "1 cup" when the label says so,
/// else one serving as a count.
FoodPortion? _serving(FoodId id, Map<String, Object?> json) {
  final grams = json['servingSize'];
  final unit = (json['servingSizeUnit'] as String?)?.toLowerCase();
  if (grams is! num || grams <= 0 || (unit != 'g' && unit != 'grm')) {
    return null;
  }
  final text = json['householdServingFullText'] as String?;
  final household = parseServingText(text);
  return FoodPortion(
    id: FoodPortionId('usda-serving:${id.value}'),
    foodId: id,
    amount: household?.quantity ?? Quantity.one,
    unit: household?.unit,
    gramWeight: grams.toDouble(),
    description: text ?? '',
  );
}
