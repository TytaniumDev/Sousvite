import 'dart:async';

import 'package:domain/domain.dart';

/// An in-memory [UserRecipePrefsRepository] for tests. Watch streams emit
/// the current value first and then only when it changes.
class FakeUserRecipePrefsRepository() implements UserRecipePrefsRepository {
  final _prefs = <RecipeId, UserRecipePrefs>{};
  final _changes = StreamController<RecipeId>.broadcast(sync: true);

  @override
  Stream<UserRecipePrefs?> watchPrefs(RecipeId recipeId) {
    StreamSubscription<RecipeId>? changes;
    late final StreamController<UserRecipePrefs?> controller;
    controller = StreamController(
      onListen: () {
        var last = _prefs[recipeId];
        controller.add(last);
        changes = _changes.stream.where((id) => id == recipeId).listen((_) {
          final next = _prefs[recipeId];
          if (next != last) controller.add(last = next);
        });
      },
      // Returning the cancel future would complete `.first` in the root
      // zone, outside a widget test's fake async.
      onCancel: () => unawaited(changes?.cancel()),
    );
    return controller.stream;
  }

  @override
  Future<void> savePrefs(UserRecipePrefs prefs) async {
    _prefs[prefs.recipeId] = prefs;
    _changes.add(prefs.recipeId);
  }
}
