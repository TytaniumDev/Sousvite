import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:recipe_import/recipe_import.dart';
import 'package:test/test.dart';

String _fixture(String name) =>
    File('test/fixtures/umami/$name').readAsStringSync();

List<int> _zip(Map<String, String> files) {
  final archive = Archive();
  for (final MapEntry(key: path, value: content) in files.entries) {
    archive.addFile(ArchiveFile.string(path, content));
  }
  return ZipEncoder().encodeBytes(archive);
}

Matcher _failsWith(UmamiFailureReason reason) => throwsA(
  isA<UmamiFailure>()
      .having((f) => f.reason, 'reason', reason)
      .having((f) => f.toString(), 'text', contains(reason.name)),
);

void main() {
  final now = DateTime.utc(2026, 11, 16);
  var nextId = 0;
  String newId() => 'id${nextId++}';

  List<UmamiRecipe> read(List<int> bytes) =>
      readUmamiArchive(bytes, newId: newId, now: now);

  group('readUmamiArchive', () {
    test('reads every page in path order, skipping other files', () {
      final recipes = read(
        _zip({
          'Weeknight/Lemon Skillet Chicken #U0026 Rice.html': _fixture(
            'skillet_chicken.html',
          ),
          'Breakfast/Plain Toast.html': _fixture('plain_toast.html'),
          '__MACOSX/Breakfast/._Plain Toast.html': 'junk',
          'Breakfast/.DS_Store': 'junk',
          'Breakfast/Empty.html': '<html><body></body></html>',
          'notes.txt': 'not a recipe',
        }),
      );

      expect(recipes.map((r) => (r.book, r.snapshot.recipe.title)), [
        ('Breakfast', 'Plain Toast'),
        ('Weeknight', 'Lemon Skillet Chicken & Rice'),
      ]);
    });

    test('fails when the file is not a zip', () {
      expect(() => read(utf8.encode('not a zip')), _failsWith(.notAnArchive));
      // A zip's signature with nothing valid after it.
      expect(
        () => read([0x50, 0x4B, 0x03, 0x04, 1, 2, 3]),
        _failsWith(.notAnArchive),
      );
    });

    test('fails when the zip has no HTML recipes, like a JSON export', () {
      expect(
        () => read(_zip({'Breakfast/Plain Toast.json': '{"name": "Toast"}'})),
        _failsWith(.noRecipes),
      );
    });
  });

  group('writeUmamiArchive', () {
    test('writes one page per recipe in its book folder', () {
      final toast = read(_zip({'a.html': _fixture('plain_toast.html')})).single;
      final chicken = read(_zip({'a.html': _fixture('skillet_chicken.html')}))
          .single;

      final bytes = writeUmamiArchive([
        chicken,
        toast,
        toast,
        (snapshot: toast.snapshot, book: null, imageUrl: null),
      ]);

      expect(ZipDecoder().decodeBytes(bytes).files.map((f) => f.name), [
        'Weeknight/Lemon Skillet Chicken & Rice.html',
        'Breakfast/Plain Toast.html',
        'Breakfast/Plain Toast (2).html',
        'Plain Toast.html',
      ]);
      expect(
        read(bytes).map((r) => (r.book, r.snapshot.recipe.title)),
        hasLength(4),
      );
    });
  });

  test('umamiFileName escapes non-ASCII characters and slashes', () {
    expect(
      umamiFileName('Marcella Hazan’s Sautéed 1/2'),
      'Marcella Hazan#U2019s Saute#U0301ed 1-2',
    );
  });
}
