import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite_widgetbook/src/directories.dart';
import 'package:sousvite_widgetbook/src/helpers/app_theme_addon.dart';
import 'package:sousvite_widgetbook/src/sousvite_widgetbook.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  final useCasePaths = WidgetbookRoot(children: directories)
      .findAll((node) => node is WidgetbookUseCase)
      .map((node) => node.path);

  group(SousviteWidgetbook, () {
    setUp(() {
      // Wide enough for the navigation, the use case, and the knobs panel.
      final view =
          TestWidgetsFlutterBinding.instance.platformDispatcher.views.single
            ..physicalSize = const Size(1600, 1000)
            ..devicePixelRatio = 1;
      addTearDown(view.reset);
    });

    testWidgets('opens on the home page', (tester) async {
      await tester.pumpWidget(const SousviteWidgetbook());
      await tester.pump();

      expect(find.byType(ThemedUseCase), findsNothing);
    });

    for (final path in useCasePaths) {
      testWidgets('renders $path with its knobs', (tester) async {
        await tester.pumpWidget(
          SousviteWidgetbook(initialRoute: '/?path=$path'),
        );
        // Some use cases animate forever (the syncing icon, a running
        // timer), so pump frames instead of settling.
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(ThemedUseCase), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('shows a use case at a desktop viewport', (tester) async {
      await tester.pumpWidget(
        const SousviteWidgetbook(
          initialRoute:
              '/?path=layout/readingcolumn/page'
              '&viewport={name:MacBook Pro}',
        ),
      );
      await tester.pump();

      // The viewport is wider than the column, so the column is centered
      // between equal insets instead of filling the viewport.
      Finder inColumn(Type type) => find
          .descendant(
            of: find.byType(ReadingColumn),
            matching: find.byType(type),
          )
          .first;
      expect(
        MediaQuery.sizeOf(tester.element(inColumn(ListView))).width,
        MacosViewports.macbookPro.width,
      );
      final list = tester.getRect(inColumn(ListView));
      final button = tester.getRect(inColumn(FilledButton));
      expect(button.width, lessThan(list.width / 2));
      expect(button.center.dx, closeTo(list.center.dx, 1));
    });

    test('offers a viewport for each window size class', () {
      expect(
        SousviteWidgetbook.viewports
            .where((viewport) => viewport != Viewports.none)
            .map((viewport) => WindowSizeClass.fromWidth(viewport.width))
            .toSet(),
        WindowSizeClass.values.toSet(),
      );
    });

    test('offers the four app themes', () {
      expect(SousviteWidgetbook.themes.map((theme) => theme.name), [
        'Light',
        'Dark',
        'Cooking light',
        'Cooking dark',
      ]);
      expect(
        SousviteWidgetbook.themes.last.data.colorScheme,
        AppTheme.cooking(.dark).colorScheme,
      );
    });
  });
}
