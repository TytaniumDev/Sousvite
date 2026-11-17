import 'dart:convert';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:sousvite/app/providers/database.dart';
import 'package:sousvite/features/account/sync/data/local_setting.dart';
import 'package:sousvite/shared/photos/photo_ref.dart';
import 'package:sousvite/shared/photos/photo_store.dart';
import 'package:sync/sync.dart';

/// Keeps recipe photos in step with a space's photo store (MEDIA-2,
/// ENGINEERING.md §7.2 and §9.1).
///
/// After each sync, every photo a recipe in the space shows that this
/// device hasn't synced yet is uploaded when it is on the device, or
/// downloaded when another device uploaded it. Synced ids are remembered
/// per transport, so a photo is handled once. A photo that is in neither
/// place yet (its device hasn't synced) is tried again next time.
final class PhotoSync({
  required final RecipeRepository recipes,
  required final RecipeSpaceRepository spaces,
  required final PhotoStore photos,
  required final SettingsDao settings,
}) {
  /// The content type of every stored photo: MEDIA-1 saves JPEGs.
  static const contentType = 'image/jpeg';

  /// Syncs the photos of the recipes in [spaceId] with [store]. [key]
  /// names the transport, so switching sources syncs every photo again.
  Future<void> run({
    required String spaceId,
    required String key,
    required BlobStore store,
  }) async {
    final done = LocalSetting(settings, 'photo_sync:$key');
    final synced = _decode(await done.read());
    final before = synced.length;
    for (final id in await _photoIds(spaceId)) {
      if (synced.contains(id)) continue;
      final local = await photos.read(id);
      if (local != null) {
        await store.put(id, local, contentType: contentType);
        synced.add(id);
      } else if (await store.get(id) case final remote?) {
        await photos.write(id, remote);
        synced.add(id);
      }
    }
    if (synced.length != before) {
      await done.write(jsonEncode(synced.toList()..sort()));
    }
  }

  /// The ids of the stored photos the recipes in [spaceId] show.
  Future<Set<String>> _photoIds(String spaceId) async {
    final ids = spaceId == privateSpaceId
        ? [
            for (final id in await recipes.watchRecipeIds().first)
              if (await spaces.sharedSpaceOf(id) == null) id,
          ]
        : await spaces.recipesInSharedSpace(spaceId);
    return {
      for (final id in ids)
        if ((await recipes.getRecipe(id))?.photoRef case final ref?)
          if (PhotoRef.parse(ref) case StoredPhoto(:final id)) id,
    };
  }

  static Set<String> _decode(String? stored) => stored == null
      ? <String>{}
      : {for (final id in jsonDecode(stored) as List<Object?>) id! as String};
}
