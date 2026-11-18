import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/import/presentation/import_screen.dart';

/// Routes owned by the import feature. Importing recipes from a URL or Umami
/// (PRD 7.2), including links and Umami exports shared from other apps.
abstract final class ImportRoutes() {
  static const path = '/import';

  /// The query parameter that carries text shared from another app.
  static const sharedParameter = 'shared';

  /// The import screen, starting an import of the link in [sharedText].
  ///
  /// The share sheet opens the app at `sousvite://open/import?shared=…`:
  /// the iOS share extension and Android's share intent both turn what
  /// was shared into this deep link.
  static String sharedLocation(String sharedText) => Uri(
    path: path,
    queryParameters: {sharedParameter: sharedText},
  ).toString();

  /// The query parameter that carries the path of a zip file shared from
  /// another app.
  static const archiveParameter = 'archive';

  /// The import screen, starting an import of the Umami export at
  /// [archivePath].
  ///
  /// Android's share intent copies the shared zip file into the app and
  /// opens `sousvite://open/import?archive=…`.
  static String archiveLocation(String archivePath) => Uri(
    path: path,
    queryParameters: {archiveParameter: archivePath},
  ).toString();

  /// Sends a zip file opened in the app to the import screen.
  ///
  /// iOS copies a zip file shared to Sousvite into the app's inbox and
  /// opens the app at that file's URL, which arrives as a location whose
  /// path is the file's. Compose it into the router's top-level redirect.
  static String? redirect(BuildContext context, GoRouterState state) {
    final location = state.uri.path;
    if (!location.toLowerCase().endsWith('.zip')) return null;
    return archiveLocation(Uri.decodeComponent(location));
  }

  static final List<RouteBase> routes = [
    GoRoute(
      path: path,
      builder: (context, state) => ImportScreen(
        sharedText: state.uri.queryParameters[sharedParameter],
        sharedArchive: state.uri.queryParameters[archiveParameter],
      ),
    ),
  ];
}
