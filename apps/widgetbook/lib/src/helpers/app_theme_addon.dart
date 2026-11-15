import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';

/// A theme picker for material_ui themes.
///
/// Widgetbook's MaterialThemeAddon takes Flutter's deprecated ThemeData, a
/// different type from material_ui's, so this sets material_ui's [Theme].
ThemeAddon<ThemeData> appThemeAddon(List<WidgetbookTheme<ThemeData>> themes) =>
    ThemeAddon(
      themes: themes,
      themeBuilder: (context, theme, child) =>
          ThemedUseCase(theme: theme, child: child),
    );

/// Shows a use case on [theme]'s surface, with its body text style.
class const ThemedUseCase({
  /// The theme to apply.
  required final ThemeData theme,

  /// The use case.
  required final Widget child,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Theme(
    data: theme,
    child: ColoredBox(
      color: theme.colorScheme.surface,
      child: DefaultTextStyle(
        style: theme.textTheme.bodyMedium ?? const TextStyle(),
        child: child,
      ),
    ),
  );
}
