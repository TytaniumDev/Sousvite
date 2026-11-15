import 'package:go_router/go_router.dart';
import 'package:sousvite/features/settings/presentation/measuring_tools_screen.dart';
import 'package:sousvite/features/settings/presentation/settings_screen.dart';

/// Routes owned by the settings feature: theme, units, measuring tools,
/// account, and about.
abstract final class SettingsRoutes() {
  static const path = '/settings';

  /// The "My measuring tools" page, inside the Settings tab.
  static const measuringToolsPath = '$path/$_measuringTools';

  static const _measuringTools = 'tools';

  static final List<RouteBase> routes = [
    GoRoute(
      path: path,
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: _measuringTools,
          builder: (context, state) => const MeasuringToolsScreen(),
        ),
      ],
    ),
  ];
}
