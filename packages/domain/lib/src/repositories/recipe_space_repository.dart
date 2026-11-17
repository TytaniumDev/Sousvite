// An interface has no code to run; only its empty primary constructor
// would show up, as an uncovered line.
// coverage:ignore-file

import 'package:domain/src/value_objects/ids.dart';

/// Which space each recipe syncs in: the user's own library, or a joint
/// share that everyone in it edits (PRD 7.10, ENGINEERING.md §8.4).
///
/// A recipe and all its parts are always in one space. Experiments, folder
/// entries, and preferences stay in the user's own library.
abstract interface class RecipeSpaceRepository() {
  /// The joint share [recipeId] is in, or null when it's only the user's,
  /// and again each time that changes.
  Stream<String?> watchSharedSpace(RecipeId recipeId);

  /// The joint share [recipeId] is in, or null when it's only the user's.
  Future<String?> sharedSpaceOf(RecipeId recipeId);

  /// Moves [recipeId] and its parts into the joint share [spaceId], so
  /// everyone in it gets the whole recipe and every later edit.
  Future<void> moveToSharedSpace(RecipeId recipeId, String spaceId);

  /// Moves [recipeId] back to the user's own library, as it is now. Later
  /// edits stay with the user; the others in the share keep their recipe.
  Future<void> moveToOwnLibrary(RecipeId recipeId);

  /// The recipes in the joint share [spaceId].
  Future<List<RecipeId>> recipesInSharedSpace(String spaceId);
}
