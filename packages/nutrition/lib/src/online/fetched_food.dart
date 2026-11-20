import 'package:domain/domain.dart';

/// A food found online, with everything needed to cache it (DATA-7), so
/// recipes that use it keep working offline.
typedef FetchedFood = ({
  Food food,
  List<FoodNutrient> nutrients,
  List<FoodPortion> portions,
});

/// A packaged product found by its barcode: the [FetchedFood] to cache, and
/// a photo of the package's front, when one is known, so the user can see
/// what they scanned before adding it. The photo is only shown, never
/// cached.
typedef BarcodeProduct = ({FetchedFood food, Uri? imageUrl});
