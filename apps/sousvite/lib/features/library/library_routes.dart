import 'package:domain/domain.dart';
import 'package:go_router/go_router.dart';
import 'package:sousvite/features/library/application/library_scope.dart';
import 'package:sousvite/features/library/presentation/folder_screen.dart';
import 'package:sousvite/features/library/presentation/library_screen.dart';

/// Routes owned by the library feature. The recipe library: folders, search,
/// and recipe cards (PRD 7.1).
abstract final class LibraryRoutes() {
  static const path = '/library';

  /// One folder's page, under the library so Back returns to it.
  static const folderPath = '$path/folders/:folderId';

  /// The page of recipes in no folder.
  static const unsortedPath = '$path/unsorted';

  /// The page listing [scope], for `context.go`.
  static String location(LibraryScope scope) => switch (scope) {
    AllRecipes() => path,
    UnsortedRecipes() => unsortedPath,
    FolderRecipes(:final folderId) => folderPath.replaceFirst(
      ':folderId',
      Uri.encodeComponent(folderId.value),
    ),
  };

  static final List<RouteBase> routes = [
    GoRoute(
      path: path,
      builder: (context, state) => const LibraryScreen(),
      routes: [
        GoRoute(
          path: 'folders/:folderId',
          builder: (context, state) => FolderScreen(
            scope: FolderRecipes(FolderId(state.pathParameters['folderId']!)),
          ),
        ),
        GoRoute(
          path: 'unsorted',
          builder: (context, state) =>
              const FolderScreen(scope: UnsortedRecipes()),
        ),
      ],
    ),
  ];
}
