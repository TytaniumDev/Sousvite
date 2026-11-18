import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/library/application/folders.dart';
import 'package:sousvite/features/library/application/library_scope.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The name of what [scope] lists, for a tile or an app bar. Watches only
/// a folder's name, so call it from `build`.
String watchScopeTitle(
  BuildContext context,
  WidgetRef ref,
  LibraryScope scope,
) => switch (scope) {
  FolderRecipes(:final folderId) =>
    ref.watch(folderNameProvider(folderId)) ?? '',
  UnsortedRecipes() => context.l10n.library_unsorted,
  AllRecipes() => context.l10n.library_allRecipes,
};
