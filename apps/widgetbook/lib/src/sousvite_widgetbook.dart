import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite_widgetbook/src/directories.dart';
import 'package:sousvite_widgetbook/src/helpers/app_theme_addon.dart';
import 'package:widgetbook/widgetbook.dart';

/// The Widgetbook: every design_system component in the app's four themes
/// (DESIGN_SYSTEM.md §3), at text scales from 100% to 200%.
class const SousviteWidgetbook({
  /// The route to open, such as `/?path=nutrition/macrobar/default`.
  /// Tests use it to open one use case.
  final String initialRoute = '/',
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Widgetbook(
    initialRoute: initialRoute,
    // Widgetbook.material builds its use cases in Flutter's deprecated
    // MaterialApp, whose Theme our widgets can't see. This app comes from
    // material_ui, like the real one.
    appBuilder: (context, child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(child: child),
    ),
    directories: directories,
    addons: [
      appThemeAddon(themes),
      // DESIGN_SYSTEM.md §12 asks every screen to work at 200%.
      TextScaleAddon(min: 1, divisions: 4),
      AlignmentAddon(),
    ],
  );

  /// Light, dark, and the high-contrast cooking variants of each.
  static final List<WidgetbookTheme<ThemeData>> themes = [
    WidgetbookTheme(name: 'Light', data: AppTheme.light()),
    WidgetbookTheme(name: 'Dark', data: AppTheme.dark()),
    WidgetbookTheme(name: 'Cooking light', data: AppTheme.cooking(.light)),
    WidgetbookTheme(name: 'Cooking dark', data: AppTheme.cooking(.dark)),
  ];
}
