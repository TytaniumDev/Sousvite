import 'package:domain/domain.dart';
import 'package:go_router/go_router.dart';
import 'package:sousvite/features/sharing/presentation/invite_screen.dart';
import 'package:sousvite/features/sharing/presentation/sharing_screen.dart';

/// Routes owned by the sharing feature. Sharing recipes and opening invite
/// links (PRD 7.10).
abstract final class SharingRoutes() {
  static const path = '/share/:recipeId';

  /// Where invite links open: `https://sousvite.web.app/invite/<id>`.
  static const invitePath = '/invite/:inviteId';

  /// The location for [recipeId], for `context.go` and `context.push`.
  static String location(RecipeId recipeId) =>
      path.replaceFirst(':recipeId', Uri.encodeComponent(recipeId.value));

  /// The location of the invite [inviteId].
  static String inviteLocation(String inviteId) =>
      invitePath.replaceFirst(':inviteId', Uri.encodeComponent(inviteId));

  static final List<RouteBase> routes = [
    GoRoute(
      path: path,
      builder: (context, state) =>
          SharingScreen(recipeId: RecipeId(state.pathParameters['recipeId']!)),
    ),
    GoRoute(
      path: invitePath,
      builder: (context, state) =>
          InviteScreen(inviteId: state.pathParameters['inviteId']!),
    ),
  ];
}
