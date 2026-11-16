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

  /// The location of a new, empty recipe.
  static String newRecipeLocation() => location(RecipeId(const Uuid().v4()));

  static final List<RouteBase> routes = [
    GoRoute(
      path: path,
      builder: (context, state) =>
          EditorScreen(recipeId: RecipeId(state.pathParameters['recipeId']!)),
    ),
  ];
}
