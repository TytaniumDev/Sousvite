import 'package:nutrition/src/online/fetched_food.dart';
import 'package:nutrition/src/online/open_food_facts_client.dart';
import 'package:nutrition/src/online/usda_branded_client.dart';

/// Branded and packaged foods from USDA and Open Food Facts together, USDA
/// first since it is the more accurate source (PRD 7.4).
///
/// Either source may be missing, such as USDA in a build without Firebase.
/// One source failing doesn't hide the other's results; only when every
/// source fails does the error reach the caller.
final class OnlineFoods({
  /// USDA Branded Foods, through our proxy.
  final UsdaBrandedClient? usda,

  /// Open Food Facts.
  final OpenFoodFactsClient? openFoodFacts,
}) {
  /// Foods matching [query] from every source.
  Future<List<FetchedFood>> search(String query) async {
    final results = await _all([
      if (usda case final usda?) () => usda.search(query),
      if (openFoodFacts case final off?) () => off.search(query),
    ]);
    return [for (final foods in results) ...foods];
  }

  /// The product with [barcode] from the first source that knows it. Its
  /// photo comes from Open Food Facts even when USDA has the nutrition,
  /// since USDA has no photos.
  Future<BarcodeProduct?> lookupBarcode(String barcode) async {
    final products = (await _all<BarcodeProduct?>([
      if (usda case final usda?)
        () async => switch (await usda.lookupBarcode(barcode)) {
          final food? => (food: food, imageUrl: null),
          null => null,
        },
      if (openFoodFacts case final off?) () => off.lookupBarcode(barcode),
    ])).nonNulls;
    if (products.firstOrNull case (:final food, imageUrl: _)) {
      return (
        food: food,
        imageUrl: products
            .map((product) => product.imageUrl)
            .nonNulls
            .firstOrNull,
      );
    }
    return null;
  }

  /// Runs [calls] together and returns the results of those that succeed,
  /// in order. Rethrows the first error when none do.
  static Future<List<T>> _all<T>(List<Future<T> Function()> calls) async {
    final outcomes = await Future.wait([
      for (final call in calls)
        call().then<(T?, Object?, StackTrace?)>(
          (value) => (value, null, null),
          onError: (Object error, StackTrace stack) => (null, error, stack),
        ),
    ]);
    final failures = outcomes.where((outcome) => outcome.$2 != null);
    if (outcomes.isNotEmpty && failures.length == outcomes.length) {
      final (_, error, stack) = failures.first;
      Error.throwWithStackTrace(error!, stack!);
    }
    return [
      for (final (value, error, _) in outcomes)
        if (error == null) value as T,
    ];
  }
}
