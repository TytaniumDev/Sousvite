import 'package:data/src/change_log/entity_codec.dart';
import 'package:data/src/change_log/field_values.dart';
import 'package:domain/domain.dart';

/// [Folder] fields in the change log.
final class FolderCodec() implements EntityCodec<Folder> {
  @override
  String get entity => 'folder';

  @override
  String idOf(Folder value) => value.id.value;

  @override
  Map<String, Object?> encode(Folder value) => {
    'name': value.name,
    'createdAt': encodeDateTime(value.createdAt),
  };

  @override
  Folder? decode(String id, Map<String, Object?> fields) {
    final name = fields['name'];
    final createdAt = decodeDateTime(fields['createdAt']);
    if (name is! String || createdAt == null) return null;
    return Folder(id: FolderId(id), name: name, createdAt: createdAt);
  }
}

/// [FolderEntry] fields in the change log. An entry has no id of its own,
/// so it is stored under [entryId], built from its folder and recipe.
final class FolderEntryCodec() implements EntityCodec<FolderEntry> {
  /// The change log id of the entry putting [recipeId] in [folderId].
  static String entryId(FolderId folderId, RecipeId recipeId) =>
      '${folderId.value}/${recipeId.value}';

  @override
  String get entity => 'folder_entry';

  @override
  String idOf(FolderEntry value) => entryId(value.folderId, value.recipeId);

  @override
  Map<String, Object?> encode(FolderEntry value) => {
    'folderId': value.folderId.value,
    'recipeId': value.recipeId.value,
    'addedAt': encodeDateTime(value.addedAt),
  };

  @override
  FolderEntry? decode(String id, Map<String, Object?> fields) {
    final addedAt = decodeDateTime(fields['addedAt']);
    if (fields
        case {
          'folderId': final String folderId,
          'recipeId': final String recipeId,
        }
        when addedAt != null) {
      return FolderEntry(
        folderId: FolderId(folderId),
        recipeId: RecipeId(recipeId),
        addedAt: addedAt,
      );
    }
    return null;
  }
}
