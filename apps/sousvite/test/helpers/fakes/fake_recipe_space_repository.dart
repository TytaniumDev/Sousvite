import 'dart:async';

import 'package:domain/domain.dart';

/// An in-memory [RecipeSpaceRepository] for tests. [watchSharedSpace]
/// emits the current space first and then only when it changes.
class FakeRecipeSpaceRepository() implements RecipeSpaceRepository {
  final _spaces = <RecipeId, String>{};
  final _changes = StreamController<void>.broadcast(sync: true);

  /// Puts [recipeId] in the joint share [spaceId].
  void seed(RecipeId recipeId, String spaceId) {
    _spaces[recipeId] = spaceId;
    _changes.add(null);
  }

  @override
  Stream<String?> watchSharedSpace(RecipeId recipeId) async* {
    yield _spaces[recipeId];
    await for (final _ in _changes.stream) {
      yield _spaces[recipeId];
    }
  }

  @override
  Future<String?> sharedSpaceOf(RecipeId recipeId) async => _spaces[recipeId];

  @override
  Future<void> moveToSharedSpace(RecipeId recipeId, String spaceId) async =>
      seed(recipeId, spaceId);

  @override
  Future<void> moveToOwnLibrary(RecipeId recipeId) async {
    _spaces.remove(recipeId);
    _changes.add(null);
  }

  @override
  Future<List<RecipeId>> recipesInSharedSpace(String spaceId) async => [
    for (final MapEntry(:key, :value) in _spaces.entries)
      if (value == spaceId) key,
  ];
}
