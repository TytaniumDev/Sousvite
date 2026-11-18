import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';

/// Which recipes a library page lists: every recipe, one folder's, or
/// those in no folder.
///
/// Every recipe belongs in a folder, so the library's main page shows
/// folders and only searches every recipe. Recipes in no folder (from
/// before folders were required, or whose last folder was deleted) show
/// in an "Unsorted" tile until they are filed.
@immutable
sealed class const LibraryScope();

/// Every recipe. The library's main page searches this.
final class const AllRecipes() extends LibraryScope {
  @override
  bool operator ==(Object other) => other is AllRecipes;

  @override
  int get hashCode => (AllRecipes).hashCode;
}

/// Recipes in no folder.
final class const UnsortedRecipes() extends LibraryScope {
  @override
  bool operator ==(Object other) => other is UnsortedRecipes;

  @override
  int get hashCode => (UnsortedRecipes).hashCode;
}

/// The recipes in one folder.
final class const FolderRecipes(
  /// The folder.
  final FolderId folderId,
) extends LibraryScope {
  @override
  bool operator ==(Object other) =>
      other is FolderRecipes && other.folderId == folderId;

  @override
  int get hashCode => folderId.hashCode;
}
