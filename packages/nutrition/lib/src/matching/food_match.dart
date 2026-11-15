import 'package:domain/domain.dart';

/// A candidate food and how well it fits an ingredient name. Higher is
/// better; scores only compare within one ranking.
final class const RankedFood({
  /// The candidate.
  required final Food food,

  /// How well the food fits.
  required final double score,
});

/// The outcome of matching one ingredient name to a food.
///
/// An ingredient is either matched or explicitly unmatched, so the app can
/// flag it instead of guessing (ENGINEERING.md §11.2).
sealed class const FoodMatch() {}

/// The ingredient matched [food].
final class const FoodMatched({
  /// The best food for the ingredient.
  required final Food food,

  /// How well it fits, from the same scale as [RankedFood.score].
  required final double score,
}) extends FoodMatch;

/// No food fits the ingredient well enough to use without asking the user.
final class const FoodUnmatched() extends FoodMatch;
