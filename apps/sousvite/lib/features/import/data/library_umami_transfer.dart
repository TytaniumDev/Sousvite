import 'package:clock/clock.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:recipe_import/recipe_import.dart';
import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/application/recipe_importers.dart';
import 'package:sousvite/features/import/application/umami_progress.dart';
import 'package:sousvite/features/import/data/umami_files.dart';

/// Reads the recipes out of an Umami export (`readUmamiArchive`).
typedef UmamiArchiveReader = Future<List<UmamiRecipe>> Function(
  Uint8List bytes, {
  required String Function() newId,
  required DateTime now,
});

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

  /// Saves the photo at an address on this device, and returns the
  /// recipe's `photoRef` for it (`RecipePhotos.importFrom`).
  required final Future<String?> Function(String? url) importPhoto,

  /// Reads the recipes out of an Umami export. Tests pass one that runs
  /// in the test's isolate.
  final UmamiArchiveReader read = _readInBackground,
}) implements UmamiTransfer {
  /// The name export offers for the file.
  static const exportFileName = 'Sousvite recipes.zip';

  /// How many photos download at once during import.
  static const photoDownloads = 6;

  /// Reads a large export off the UI isolate, so the progress dialog keeps
  /// moving.
  static Future<List<UmamiRecipe>> _readInBackground(
    Uint8List bytes, {
    required String Function() newId,
    required DateTime now,
  }) => compute(_readArchive, (bytes: bytes, newId: newId, now: now));

  static List<UmamiRecipe> _readArchive(
    ({Uint8List bytes, String Function() newId, DateTime now}) input,
  ) => readUmamiArchive(input.bytes, newId: input.newId, now: input.now);

  @override
  Future<int?> importLibrary({required UmamiProgressReport onProgress}) async {
    final bytes = await files.pickArchive();
    if (bytes == null) return null;
    final count = await _importArchive(bytes, onProgress);
    return count;
  }

  @override
  Future<int> importSharedArchive(
    String path, {
    required UmamiProgressReport onProgress,
  }) async {
    onProgress(const UmamiImportProgress(.reading));
    final bytes = await files.takeSharedArchive(path);
    if (bytes == null) throw const ImportFailure(.invalidFile);
    final count = await _importArchive(bytes, onProgress);
    return count;
  }

  /// Saves the recipes in the Umami export [bytes], then their photos, and
  /// returns how many recipes. Recipes come first so they show in the
  /// library while the slower photo downloads run.
  Future<int> _importArchive(
    Uint8List bytes,
    UmamiProgressReport onProgress,
  ) async {
    onProgress(const UmamiImportProgress(.reading));
    final List<UmamiRecipe> imported;
    try {
      imported = await read(bytes, newId: newId, now: clock.now());
    } on UmamiFailure {
      throw const ImportFailure(.invalidFile);
    }
    final folderIds = {
      for (final folder in await folders.watchFolders().first)
        folder.name: folder.id,
    };
    final total = imported.length;
    onProgress(UmamiImportProgress(.recipes, total: total));
    for (final (index, (:snapshot, :book, imageUrl: _)) in imported.indexed) {
      await recipes.saveSnapshot(snapshot);
      if (book != null && book.trim().isNotEmpty) {
        final folderId = folderIds[book] ??= await _newFolder(book);
        await folders.addRecipeToFolder(folderId, snapshot.recipe.id);
      }
      onProgress(UmamiImportProgress(.recipes, done: index + 1, total: total));
    }
    await _importPhotos([
      for (final (:snapshot, book: _, :imageUrl) in imported)
        if (imageUrl != null && imageUrl.trim().isNotEmpty)
          (recipe: snapshot.recipe, url: imageUrl),
    ], onProgress);
    return total;
  }

  /// Saves each recipe's photo, downloading [photoDownloads] at a time.
  Future<void> _importPhotos(
    List<({Recipe recipe, String url})> photos,
    UmamiProgressReport onProgress,
  ) async {
    final total = photos.length;
    if (total == 0) return;
    var done = 0;
    onProgress(UmamiImportProgress(.photos, total: total));
    for (var start = 0; start < total; start += photoDownloads) {
      final batch = photos.skip(start).take(photoDownloads);
      await Future.wait(
        batch.map((photo) async {
          final photoRef = await importPhoto(photo.url);
          if (photoRef != null) {
            await recipes.saveRecipe(photo.recipe.copyWith(photoRef: photoRef));
          }
          onProgress(UmamiImportProgress(.photos, done: ++done, total: total));
        }),
      );
    }
  }

  @override
  Future<int?> exportLibrary() async {
    final recipeIds = await recipes.watchRecipeIds().first;
    if (recipeIds.isEmpty) return 0;
    final books = await _firstBooks();
    final exported = [
      for (final id in recipeIds)
        if (await _snapshot(id) case final snapshot?)
          (
            snapshot: snapshot,
            book: books[id],
            imageUrl: _photoAddress(snapshot.recipe.photoRef),
          ),
    ];
    final saved = await files.saveArchive(
      exportFileName,
      writeUmamiArchive(exported),
    );
    return saved ? exported.length : null;
  }

  /// The photo's address for Umami, which can only point at the web. A
  /// photo saved only on this device stays behind.
  static String? _photoAddress(String? photoRef) {
    final url = photoRef == null ? null : Uri.tryParse(photoRef);
    return url != null && (url.isScheme('http') || url.isScheme('https'))
        ? photoRef
        : null;
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
