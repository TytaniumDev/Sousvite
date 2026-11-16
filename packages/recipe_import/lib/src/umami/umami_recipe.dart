import 'package:domain/domain.dart';

/// One recipe in an Umami export: the recipe, the name of the Umami recipe
/// book it is in (a folder here), and its photo's address.
typedef UmamiRecipe = ({
  RecipeSnapshot snapshot,
  String? book,
  String? imageUrl,
});

/// Why a file couldn't be read as an Umami export.
enum UmamiFailureReason() {
  /// The file isn't a zip archive.
  notAnArchive,

  /// The archive has no recipes in Umami's HTML export format. Umami's
  /// JSON export lands here too.
  noRecipes,
}

/// A file that couldn't be read as an Umami export.
final class const UmamiFailure(
  /// Why.
  final UmamiFailureReason reason,
) implements Exception {
  @override
  String toString() => 'UmamiFailure(${reason.name})';
}
