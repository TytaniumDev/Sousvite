import 'package:clock/clock.dart';
import 'package:domain/domain.dart';
import 'package:recipe_import/recipe_import.dart';
import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/application/recipe_importers.dart';
import 'package:sousvite/features/import/data/umami_files.dart';

/// Moves the whole library in and out of Umami's HTML export, keeping
/// Umami recipe books as folders (ENGINEERING.md §14).
class const LibraryUmamiTransfer({
  /// Picks and saves the export file.
  required final UmamiFiles files,

  /// Where recipes are saved and read.
  required final RecipeRepository recipes,

  /// Where recipe books become folders.
  required final FolderRepository folders,

  /// Makes ids for imported recipes and new folders.
  required final String Function() newId,
}) implements UmamiTransfer {
  /// The name export offers for the file.
  static const exportFileName = 'Sousvite recipes.zip';

  @override
  Future<int?> importLibrary() async {
    final bytes = await files.pickArchive();
    if (bytes == null) return null;
    final List<UmamiRecipe> imported;
    try {
      imported = readUmamiArchive(bytes, newId: newId, now: clock.now());
    } on UmamiFailure {
      throw const ImportFailure(.invalidFile);
    }
    final folderIds = {
      for (final folder in await folders.watchFolders().first)
        folder.name: folder.id,
    };
    for (final (:snapshot, :book, imageUrl: _) in imported) {
      await recipes.saveSnapshot(snapshot);
      if (book == null || book.trim().isEmpty) continue;
      final folderId = folderIds[book] ??= await _newFolder(book);
      await folders.addRecipeToFolder(folderId, snapshot.recipe.id);
    }
    return imported.length;
  }

  @override
  Future<int?> exportLibrary() async {
    final recipeIds = await recipes.watchRecipeIds().first;
    if (recipeIds.isEmpty) return 0;
    final books = await _firstBooks();
    final exported = [
      for (final id in recipeIds)
        if (await _snapshot(id) case final snapshot?)
          (snapshot: snapshot, book: books[id], imageUrl: null),
    ];
    final saved = await files.saveArchive(
      exportFileName,
      writeUmamiArchive(exported),
    );
    return saved ? exported.length : null;
  }

  Future<FolderId> _newFolder(String name) async {
    final folder = Folder(
      id: FolderId(newId()),
      name: name,
      createdAt: clock.now(),
    );
    await folders.saveFolder(folder);
    return folder.id;
  }

  /// Each filed recipe's book: the first of its folders, in the order the
  /// library lists them. Umami keeps a recipe in one book.
  Future<Map<RecipeId, String>> _firstBooks() async {
    final books = <RecipeId, String>{};
    for (final folder in await folders.watchFolders().first) {
      for (final id in await folders.watchRecipeIdsInFolder(folder.id).first) {
        books.putIfAbsent(id, () => folder.name);
      }
    }
    return books;
  }

  /// The recipe [id] with all its parts, or null once it's deleted.
  Future<RecipeSnapshot?> _snapshot(RecipeId id) async {
    final recipe = await recipes.getRecipe(id);
    if (recipe == null) return null;
    return RecipeSnapshot(
      recipe: recipe,
      ingredientSections: await recipes.watchIngredientSections(id).first,
      ingredientLines: await recipes.watchIngredientLines(id).first,
      stepSections: await recipes.watchStepSections(id).first,
      steps: await recipes.watchSteps(id).first,
    );
  }
}
