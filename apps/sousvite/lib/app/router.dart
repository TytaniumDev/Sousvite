import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/app_shell.dart';
import 'package:sousvite/features/account/account.dart';
import 'package:sousvite/features/cooking/cooking.dart';
import 'package:sousvite/features/editor/editor.dart';
import 'package:sousvite/features/experiments/experiments.dart';
import 'package:sousvite/features/feedback/feedback.dart';
import 'package:sousvite/features/grocery/grocery.dart';
import 'package:sousvite/features/import/import.dart';
import 'package:sousvite/features/library/library.dart';
import 'package:sousvite/features/nutrition/nutrition.dart';
import 'package:sousvite/features/recipe/recipe.dart';
import 'package:sousvite/features/settings/settings.dart';
import 'package:sousvite/features/sharing/sharing.dart';

part 'router.g.dart';

/// The app's routes, composed from each feature's `<name>_routes.dart`.
///
/// Features add and change routes only in their own routes file. This file
/// changes only when a feature is added.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final router = GoRouter(
    initialLocation: LibraryRoutes.path,
    // Files opened in the app arrive as locations of their own.
    redirect: ImportRoutes.redirect,
    routes: [
      // Top-level destinations keep their own navigation stacks.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: LibraryRoutes.routes),
          StatefulShellBranch(routes: GroceryRoutes.routes),
          StatefulShellBranch(routes: SettingsRoutes.routes),
        ],
      ),
      // Full-screen routes, shown on top of the shell.
      ...RecipeRoutes.routes,
      ...EditorRoutes.routes,
      ...ImportRoutes.routes,
      ...NutritionRoutes.routes,
      ...CookingRoutes.routes,
      ...ExperimentsRoutes.routes,
      ...SharingRoutes.routes,
      ...AccountRoutes.routes,
      ...FeedbackRoutes.routes,
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}
