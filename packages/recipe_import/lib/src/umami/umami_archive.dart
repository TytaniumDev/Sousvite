import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:recipe_import/src/umami/umami_html.dart';
import 'package:recipe_import/src/umami/umami_recipe.dart';

/// Every recipe in an Umami HTML export, the zip file Umami's "Export
/// recipes" gives (PRD 7.2), in path order. Recipes get new ids from
/// [newId].
///
/// Each recipe is an `.html` file in a folder named after its recipe book.
/// Throws [UmamiFailure] when [bytes] aren't a zip or hold no recipes.
List<UmamiRecipe> readUmamiArchive(
  List<int> bytes, {
  required String Function() newId,
  required DateTime now,
}) {
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
  } on Object {
    // The decoder throws different errors for different kinds of damage.
    throw const UmamiFailure(.notAnArchive);
  }
  // Bytes that aren't a zip at all decode as an empty archive.
  if (archive.isEmpty) throw const UmamiFailure(.notAnArchive);
  final pages =
      archive.files
          .where((file) => file.isFile && _isRecipePage(file.name))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
  final recipes = [
    for (final file in pages)
      ?readUmamiHtml(
        utf8.decode(file.content, allowMalformed: true),
        newId: newId,
        now: now,
      ),
  ];
  if (recipes.isEmpty) throw const UmamiFailure(.noRecipes);
  return recipes;
}

/// [recipes] as an Umami HTML export that [readUmamiArchive] reads back:
/// one page per recipe, in a folder named after its book, or at the top
/// when it has none. Names Umami can't use in a path are escaped the way
/// Umami does, and repeated names get a number.
Uint8List writeUmamiArchive(Iterable<UmamiRecipe> recipes) {
  final archive = Archive();
  final used = <String>{};
  for (final recipe in recipes) {
    final folder = switch (recipe.book) {
      null => '',
      final book => '${umamiFileName(book)}/',
    };
    final base = '$folder${umamiFileName(recipe.snapshot.recipe.title)}';
    var path = '$base.html';
    for (var copy = 2; !used.add(path); copy++) {
      path = '$base ($copy).html';
    }
    archive.addFile(ArchiveFile.string(path, writeUmamiHtml(recipe)));
  }
  return ZipEncoder().encodeBytes(archive);
}

/// [name] as Umami writes it in a file name: each character outside ASCII
/// as `#U` and four hex digits, and path separators as dashes.
String umamiFileName(String name) {
  final escaped = StringBuffer();
  for (final unit in name.replaceAll(RegExp(r'[/\\]'), '-').codeUnits) {
    escaped.write(
      unit < 0x80
          ? String.fromCharCode(unit)
          : '#U${unit.toRadixString(16).toUpperCase().padLeft(4, '0')}',
    );
  }
  return escaped.toString();
}

/// Recipe pages, skipping the metadata macOS adds when it zips a folder.
bool _isRecipePage(String path) =>
    path.toLowerCase().endsWith('.html') &&
    !path.split('/').any((part) => part.startsWith('.') || part == '__MACOSX');
