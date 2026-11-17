import 'package:data/data.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/sqlite/open_sqlite3.dart';

part 'bundled_foods.g.dart';

/// Where the bundled USDA foods ship, built by `tools/usda_builder`.
const bundledFoodsAsset = 'assets/nutrition/usda_foods.sqlite';

/// The bundled USDA foods, opened from the app's asset.
///
/// Loads in the background, so the first frame doesn't wait for the 9 MB
/// file; the food repository reads only cached foods until it has loaded.
@Riverpod(keepAlive: true)
Future<BundledFoods> bundledFoods(Ref ref) async {
  final bytes = await rootBundle.load(bundledFoodsAsset);
  final foods = BundledFoods.fromBytes(
    await openSqlite3(),
    bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
  );
  ref.onDispose(foods.close);
  return foods;
}
