import 'package:domain/domain.dart';
import 'package:go_router/go_router.dart';
import 'package:sousvite/features/editor/presentation/editor_screen.dart';
import 'package:uuid/uuid.dart';

/// Routes owned by the editor feature. Creating and editing recipes (PRD 7.3).
abstract final class EditorRoutes() {
  static const path = '/editor/:recipeId';

  /// The location for [recipeId], for `context.go` and `context.push`.
  static String location(RecipeId recipeId) =>
      path.replaceFirst(':recipeId', Uri.encodeComponent(recipeId.value));

  /// The query parameter that carries the folder a new recipe goes into.
  static const folderParameter = 'folder';

  /// The location of a new, empty recipe, saved into [folderId] (every
  /// recipe belongs in a folder).
  static String newRecipeLocation({FolderId? folderId}) => Uri(
    path: location(RecipeId(const Uuid().v4())),
    queryParameters: folderId == null
        ? null
        : {folderParameter: folderId.value},
  ).toString();

  static final List<RouteBase> routes = [
    GoRoute(
      path: path,
      builder: (context, state) => EditorScreen(
        recipeId: RecipeId(state.pathParameters['recipeId']!),
        folderId: switch (state.uri.queryParameters[folderParameter]) {
          final String id => FolderId(id),
          null => null,
        },
      ),
    ),
  ];
}
