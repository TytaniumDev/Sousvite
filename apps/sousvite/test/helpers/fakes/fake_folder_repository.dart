import 'dart:async';

import 'package:collection/collection.dart';
import 'package:domain/domain.dart';

/// An in-memory [FolderRepository] for tests. Watch streams emit the
/// current value first and then only when it changes.
class FakeFolderRepository() implements FolderRepository {
  final _folders = <FolderId, Folder>{};
  final _entries = <FolderId, List<RecipeId>>{};
  final _changes = StreamController<void>.broadcast(sync: true);

  /// Adds [folder] holding [recipeIds].
  void seed(Folder folder, [List<RecipeId> recipeIds = const []]) {
    _folders[folder.id] = folder;
    _entries[folder.id] = [...recipeIds];
    _changes.add(null);
  }

  /// Every folder, read synchronously for widget tests.
  List<Folder> get allFolders => [..._folders.values];

  /// The recipes in [folderId], read synchronously for widget tests.
  List<RecipeId> recipeIdsIn(FolderId folderId) => [...?_entries[folderId]];

  Stream<T> _watch<T>(T Function() read) {
    StreamSubscription<void>? changes;
    late final StreamController<T> controller;
    controller = StreamController<T>(
      onListen: () {
        var last = read();
        controller.add(last);
        changes = _changes.stream.listen((_) {
          final next = read();
          if (!const DeepCollectionEquality().equals(next, last)) {
            controller.add(last = next);
          }
        });
      },
      // Returning the cancel future would complete `.first` in the root
      // zone, outside a widget test's fake async.
      onCancel: () => unawaited(changes?.cancel()),
    );
    return controller.stream;
  }

  @override
  Stream<List<Folder>> watchFolders() =>
      _watch(() => _folders.values.sortedBy((f) => f.name.toLowerCase()));

  @override
  Stream<List<RecipeId>> watchRecipeIdsInFolder(FolderId folderId) =>
      _watch(() => [...?_entries[folderId]]);

  @override
  Stream<Set<RecipeId>> watchRecipeIdsInAnyFolder() => _watch(
    () => {
      for (final MapEntry(:key, :value) in _entries.entries)
        if (_folders.containsKey(key)) ...value,
    },
  );

  @override
  Future<Folder?> getFolder(FolderId id) async => _folders[id];

  @override
  Future<void> saveFolder(Folder folder) async {
    _folders[folder.id] = folder;
    _entries.putIfAbsent(folder.id, () => []);
    _changes.add(null);
  }

  @override
  Future<void> deleteFolder(FolderId id) async {
    _folders.remove(id);
    _entries.remove(id);
    _changes.add(null);
  }

  @override
  Future<void> addRecipeToFolder(FolderId folderId, RecipeId recipeId) async {
    final entries = _entries.putIfAbsent(folderId, () => []);
    if (!entries.contains(recipeId)) entries.add(recipeId);
    _changes.add(null);
  }

  @override
  Future<void> removeRecipeFromFolder(
    FolderId folderId,
    RecipeId recipeId,
  ) async {
    _entries[folderId]?.remove(recipeId);
    _changes.add(null);
  }
}
