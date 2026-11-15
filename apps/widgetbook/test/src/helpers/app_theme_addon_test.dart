import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite_widgetbook/src/helpers/app_theme_addon.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  group(ThemedUseCase, () {
    testWidgets('applies the theme and paints its surface', (tester) async {
      final theme = AppTheme.dark();
      late ThemeData seen;
      await tester.pumpWidget(
        ThemedUseCase(
          theme: theme,
          child: Builder(
            builder: (context) {
              seen = Theme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(seen.colorScheme, theme.colorScheme);
      expect(
        tester.widget<ColoredBox>(find.byType(ColoredBox)).color,
        theme.colorScheme.surface,
      );
    });
  });

  group('appThemeAddon', () {
    testWidgets('builds the picked theme around the use case', (tester) async {
      final themes = [WidgetbookTheme(name: 'Light', data: AppTheme.light())];
      final addon = appThemeAddon(themes);

      await tester.pumpWidget(
        Builder(
          builder: (context) =>
              addon.buildUseCase(context, const SizedBox(), themes.single),
        ),
      );

      expect(find.byType(ThemedUseCase), findsOneWidget);
    });
  });
}
