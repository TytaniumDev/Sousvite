/// What a recipe page says, before it becomes app entities: the fields
/// schema.org `Recipe` markup and the heuristics can find.
final class const RecipePageData({
  /// The recipe's name.
  required final String name,

  /// Ingredient lines as written, each with the section heading above it,
  /// if any.
  final List<({String? section, String text})> ingredients = const [],

  /// Steps as written, each with the section heading above it, if any.
  final List<({String? section, String text})> steps = const [],

  /// The yield as written: "4 servings", "12", "1 loaf".
  final String? yield,

  /// Times as written in ISO 8601: "PT1H30M".
  final String? prepTime,
  final String? cookTime,
  final String? totalTime,

  /// The site's own name, such as "Serious Eats".
  final String? siteName,

  /// A photo of the dish.
  final String? imageUrl,
});
