import 'package:domain/domain.dart';
import 'package:sousvite/app/services/nutrition_api.dart';

/// A food the user can pick when changing a match (PRD 7.4).
sealed class const FoodChoice() {
  Food get food;
}

/// A bundled or already cached food.
final class const SavedFoodChoice(@override final Food food) extends FoodChoice;

/// A branded food found online. Picking it caches it, so the recipe keeps
/// working offline.
final class const OnlineFoodChoice(final OnlineFood online) extends FoodChoice {
  @override
  Food get food => online.food;
}
