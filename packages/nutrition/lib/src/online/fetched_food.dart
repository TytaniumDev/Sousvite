import 'package:domain/domain.dart';

/// A food found online, with everything needed to cache it (DATA-7), so
/// recipes that use it keep working offline.
typedef FetchedFood = ({
  Food food,
  List<FoodNutrient> nutrients,
  List<FoodPortion> portions,
});
