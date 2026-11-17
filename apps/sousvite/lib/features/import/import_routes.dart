import 'package:go_router/go_router.dart';
import 'package:sousvite/features/import/presentation/import_screen.dart';

/// Routes owned by the import feature. Importing recipes from a URL or Umami
/// (PRD 7.2).
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

  static final List<RouteBase> routes = [
    GoRoute(
      path: path,
      builder: (context, state) =>
          ImportScreen(sharedText: state.uri.queryParameters[sharedParameter]),
    ),
  ];
}
