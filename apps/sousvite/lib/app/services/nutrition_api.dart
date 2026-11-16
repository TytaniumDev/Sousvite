import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nutrition/nutrition.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/services/firebase.dart';

part 'nutrition_api.g.dart';

/// A food found online, with everything needed to cache it.
typedef OnlineFood = FetchedFood;

/// Online food lookups: USDA branded foods through our proxy and Open Food
/// Facts (ENGINEERING.md §11.1).
abstract interface class NutritionApi() {
  Future<List<OnlineFood>> search(String query);

  Future<OnlineFood?> lookupBarcode(String barcode);
}

/// Finds nothing, as if offline. Bundled generic foods still work.
class const OfflineNutritionApi() implements NutritionApi {
  @override
  Future<List<OnlineFood>> search(String query) async => const [];

  @override
  Future<OnlineFood?> lookupBarcode(String barcode) async => null;
}

/// Searches USDA Branded Foods and Open Food Facts with `nutrition`'s
/// [OnlineFoods].
class const OnlineNutritionApi(final OnlineFoods _foods)
    implements NutritionApi {
  @override
  Future<List<OnlineFood>> search(String query) => _foods.search(query);

  @override
  Future<OnlineFood?> lookupBarcode(String barcode) =>
      _foods.lookupBarcode(barcode);
}

/// Calls the `usdaProxy` function. Callable results arrive as maps keyed
/// by `Object?`; a JSON round trip gives the parser plain JSON maps.
UsdaProxyCall usdaProxyCall(FirebaseFunctions functions) => (request) async {
  final result = await functions
      .httpsCallable('usdaProxy')
      .call<Object?>(request);
  return jsonDecode(jsonEncode(result.data));
};

/// Fetches with [client], reading the body as UTF-8 whatever the headers
/// say, and throws on any status but 200.
HttpGet httpGet(http.Client client) => (url, headers) async {
  final response = await client.get(url, headers: headers);
  if (response.statusCode != 200) {
    throw http.ClientException('HTTP ${response.statusCode}', url);
  }
  return utf8.decode(response.bodyBytes);
};

/// USDA through our proxy when Firebase is set up, and Open Food Facts
/// always. Browsers don't let pages set a `User-Agent`, so web sends none.
@Riverpod(keepAlive: true)
NutritionApi nutritionApi(Ref ref) {
  final app = ref.watch(firebaseAppProvider);
  final client = http.Client();
  ref.onDispose(client.close);
  return OnlineNutritionApi(
    OnlineFoods(
      usda: app == null
          ? null
          : UsdaBrandedClient(
              usdaProxyCall(
                FirebaseFunctions.instanceFor(app: app, region: 'us-central1'),
              ),
            ),
      openFoodFacts: OpenFoodFactsClient(
        httpGet(client),
        userAgent: kIsWeb ? null : OpenFoodFactsClient.defaultUserAgent,
      ),
    ),
  );
}
