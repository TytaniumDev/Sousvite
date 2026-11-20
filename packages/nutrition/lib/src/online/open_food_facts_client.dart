import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:nutrition/src/online/fetched_food.dart';
import 'package:nutrition/src/online/serving_text.dart';

/// Fetches [url] with [headers] and returns the response body, throwing
/// on a network error or a status other than 200.
typedef HttpGet = Future<String> Function(Uri url, Map<String, String> headers);

/// Searches Open Food Facts' public API for packaged products. Its data is
/// ODbL, so every food it returns keeps [NutritionSource.openFoodFacts] as
/// its attribution, and settings credits it (ENGINEERING.md §11.1).
final class OpenFoodFactsClient(
  /// Sends the request.
  final HttpGet _get, {

  /// Identifies the app, as Open Food Facts asks. Null where the platform
  /// won't let apps set it, as in browsers.
  final String? userAgent = defaultUserAgent,

  /// The API's address.
  final Uri? baseUrl,

  /// Results per search.
  final int pageSize = 20,
}) {
  /// Who we are, with a link to the code for contact.
  static const defaultUserAgent =
      'Sousvite/1.0 (+https://github.com/TytaniumDev/Sousvite)';

  static final _defaultBaseUrl = Uri.https('world.openfoodfacts.org');

  Uri get _base => baseUrl ?? _defaultBaseUrl;

  Map<String, String> get _headers => {'User-Agent': ?userAgent};

  /// Products matching [query], with nutrients per 100 g.
  Future<List<FetchedFood>> search(String query) async {
    final url = _base.replace(
      path: '/cgi/search.pl',
      queryParameters: {
        'search_terms': query,
        'search_simple': '1',
        'json': '1',
        'page_size': '$pageSize',
        'fields': _fields,
      },
    );
    return parseOffSearch(jsonDecode(await _get(url, _headers)));
  }

  /// The product with [barcode], with a photo of its front, or null if
  /// Open Food Facts doesn't know it.
  Future<BarcodeProduct?> lookupBarcode(String barcode) async {
    final url = _base.replace(
      path: '/api/v2/product/${Uri.encodeComponent(barcode)}',
      queryParameters: {'fields': '$_fields,image_front_url'},
    );
    final response = jsonDecode(await _get(url, _headers));
    if (response case {'status': 1, 'product': final Map<String, Object?> p}) {
      if (_product(p) case final food?) {
        return (food: food, imageUrl: _imageUrl(p['image_front_url']));
      }
    }
    return null;
  }

  static const _fields =
      'code,product_name,brands,nutriments,serving_quantity,'
      'serving_quantity_unit,serving_size';
}

/// The products in an Open Food Facts search response. Products without a
/// name, a barcode, or calories are skipped.
List<FetchedFood> parseOffSearch(Object? response) {
  if (response is! Map || response['products'] is! List) return const [];
  return [
    for (final product in response['products'] as List)
      if (product is Map<String, Object?>) ?_product(product),
  ];
}

/// Open Food Facts nutriment keys, per 100 g, with the USDA nutrient number
/// each is stored under and the factor from OFF's unit (grams, except
/// energy in kcal) to USDA's.
const _nutriments = {
  'energy-kcal_100g': ('208', 1.0),
  'proteins_100g': ('203', 1.0),
  'carbohydrates_100g': ('205', 1.0),
  'fat_100g': ('204', 1.0),
  'saturated-fat_100g': ('606', 1.0),
  'trans-fat_100g': ('605', 1.0),
  'fiber_100g': ('291', 1.0),
  'sugars_100g': ('269', 1.0),
  'cholesterol_100g': ('601', 1000.0),
  'sodium_100g': ('307', 1000.0),
  'calcium_100g': ('301', 1000.0),
  'iron_100g': ('303', 1000.0),
  'potassium_100g': ('306', 1000.0),
  'vitamin-c_100g': ('401', 1000.0),
  'vitamin-a_100g': ('320', 1000000.0),
  'vitamin-d_100g': ('328', 1000000.0),
};

FetchedFood? _product(Map<String, Object?> json) {
  final code = json['code'];
  final name = (json['product_name'] as String?)?.trim();
  final nutriments = json['nutriments'];
  if (code is! String || code.isEmpty || name == null || name.isEmpty) {
    return null;
  }
  if (nutriments is! Map || nutriments['energy-kcal_100g'] is! num) {
    return null;
  }
  final id = FoodId('off:$code');
  final brands = (json['brands'] as String?)?.split(',').first.trim();
  // A serving in milliliters can't be weighed without a density.
  final serving = switch (json['serving_quantity_unit']) {
    null || 'g' => json['serving_quantity'],
    _ => null,
  };
  return (
    food: Food(
      id: id,
      source: .openFoodFacts,
      externalId: code,
      name: name,
      brand: brands == null || brands.isEmpty ? null : brands,
    ),
    nutrients: [
      for (final MapEntry(key: offKey, value: (usdaCode, factor))
          in _nutriments.entries)
        if (nutriments[offKey] case final num value)
          FoodNutrient(
            foodId: id,
            nutrientCode: usdaCode,
            amountPer100g: value * factor,
          ),
    ],
    portions: [
      if (serving is num && serving > 0)
        _serving(id, code, serving, json['serving_size'] as String?),
    ],
  );
}

/// The photo at [value], if it is a web address.
Uri? _imageUrl(Object? value) => switch (value) {
  final String text => switch (Uri.tryParse(text)) {
    final Uri url when url.isScheme('https') || url.isScheme('http') => url,
    _ => null,
  },
  _ => null,
};

/// The label serving weighing [grams]: "2 tbsp" when [text] starts with a
/// household volume, as in "2 tbsp (32 g)", else one serving as a count.
FoodPortion _serving(FoodId id, String code, num grams, String? text) {
  final household = parseServingText(text?.split('(').first);
  final volume = household?.unit?.dimension == .volume ? household : null;
  return FoodPortion(
    id: FoodPortionId('off-serving:$code'),
    foodId: id,
    amount: volume?.quantity ?? Quantity.one,
    unit: volume?.unit,
    gramWeight: grams.toDouble(),
    description: text ?? '',
  );
}
