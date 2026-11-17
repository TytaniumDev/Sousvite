import 'dart:convert';

import 'package:data/src/app_database.dart';
import 'package:drift/drift.dart';

/// Which space a recipe and its parts sync in (ENGINEERING.md §8.4).
///
/// A recipe in a joint share syncs in that share's space; every other
/// recipe syncs in the user's own library. The space is kept as the
/// recipe's [field], a change like any other, so it syncs to the user's
/// other devices and to everyone in the share, and the latest move wins.
/// A recipe with no such change is in the user's own library.
final class RecipeSpaces(final AppDatabase _database) {
  /// The change log field on a `recipe` that holds its shared space id, or
  /// null for the user's own library.
  static const field = '_space';

  /// The joint share [recipeId] is in, or null when it's only the user's.
  Future<String?> sharedSpaceOf(String recipeId) async {
    final row = await _database.syncDao.latestForField(
      entity: 'recipe',
      entityId: recipeId,
      field: field,
    );
    return row == null ? null : jsonDecode(row.value) as String?;
  }

  /// [sharedSpaceOf], and again each time it changes.
  Stream<String?> watchSharedSpaceOf(String recipeId) {
    final log = _database.changeLog;
    final query = _database.select(log)
      ..where(
        (row) =>
            row.entity.equals('recipe') &
            row.entityId.equals(recipeId) &
            row.field.equals(field),
      )
      ..orderBy([(row) => OrderingTerm.desc(row.hlc)])
      ..limit(1);
    return query
        .watchSingleOrNull()
        .map((row) => row == null ? null : jsonDecode(row.value) as String?)
        .distinct();
  }

  /// The recipes whose current space is [spaceId].
  Future<List<String>> recipesIn(String spaceId) async {
    final winners = await _database.syncDao.winnersInSpace(spaceId);
    final encoded = jsonEncode(spaceId);
    return [
      for (final row in winners)
        if (row.entity == 'recipe' &&
            row.field == field &&
            row.value == encoded)
          row.entityId,
    ];
  }
}
