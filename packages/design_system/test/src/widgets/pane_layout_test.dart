import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _main = Key('main');
const _side = Key('side');
const _one = Key('one');

/// A pane's scroll view with one row in it, keyed so tests can find both.
Widget _pane(Key key, EdgeInsets insets) => ListView(
  key: key,
  padding: insets,
  children: [SizedBox(key: ValueKey(key), height: 48)],
);

Future<void> _pump(
  WidgetTester tester, {
  required double width,
  PaneSide sideAt = .end,
  TextDirection direction = .ltr,
}) {
  // A window wide enough for any layout under test.
  tester.view
    ..physicalSize = const Size(2000, 800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: Center(
          child: SizedBox(
            width: width,
            height: 600,
            child: PaneLayout(
              sideAt: sideAt,
              main: (context, insets) => _pane(_main, insets),
              side: (context, insets) => _pane(_side, insets),
              onePane: (context, insets) => _pane(_one, insets),
            ),
          ),
        ),
      ),
    ),
  );
}

extension on WidgetTester {
  /// Where the row inside the pane with [key] sits.
  Rect rowOf(Key key) => getRect(find.byKey(ValueKey(key)));
}

void main() {
  group(PaneLayout, () {
    testWidgets('shows one centered column below the expanded size', (
      tester,
    ) async {
      await _pump(tester, width: PaneLayout.twoPaneMinWidth - 1);

      expect(find.byKey(_one), findsOneWidget);
      expect(find.byKey(_main), findsNothing);
      expect(find.byKey(_side), findsNothing);
      expect(tester.rowOf(_one).width, ReadingColumn.readingWidth);
    });

    testWidgets('shows a fixed side pane beside the main pane', (tester) async {
      await _pump(tester, width: PaneLayout.twoPaneMinWidth);

      expect(find.byKey(_one), findsNothing);
      final main = tester.rowOf(_main);
      final side = tester.rowOf(_side);
      // 8 dp outer insets: the content's own 16 dp makes the 24 dp margin.
      expect(main.left - tester.getRect(find.byKey(_main)).left, 8);
      expect(side.width, PaneLayout.sideWidth);
      expect(side.left - main.right, WindowSizeClass.paneSpacer);
    });

    testWidgets('puts the side pane first when asked', (tester) async {
      await _pump(tester, width: 1000, sideAt: .start);

      expect(
        tester.rowOf(_main).left - tester.rowOf(_side).right,
        WindowSizeClass.paneSpacer,
      );
    });

    testWidgets('mirrors in right-to-left languages', (tester) async {
      await _pump(tester, width: 1000, sideAt: .start, direction: .rtl);

      expect(
        tester.rowOf(_side).left - tester.rowOf(_main).right,
        WindowSizeClass.paneSpacer,
      );
    });

    testWidgets('keeps the panes together in the middle of wide windows', (
      tester,
    ) async {
      await _pump(tester, width: 2000);

      final main = tester.rowOf(_main);
      final side = tester.rowOf(_side);
      expect(main.width, ReadingColumn.readingWidth);
      expect(side.width, PaneLayout.sideWidth);
      // The pair is centered, and each scroll view reaches the window edge.
      expect(main.left, 2000 - side.right);
      expect(tester.getRect(find.byKey(_main)).left, 0);
      expect(tester.getRect(find.byKey(_side)).right, 2000);
    });

    testWidgets('gives only the main pane the primary scroll controller', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      tester.view
        ..physicalSize = const Size(1200, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        Directionality(
          textDirection: .ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: PrimaryScrollController(
              controller: controller,
              automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
              child: PaneLayout(
                main: (context, insets) => _pane(_main, insets),
                side: (context, insets) => _pane(_side, insets),
                onePane: (context, insets) => _pane(_one, insets),
              ),
            ),
          ),
        ),
      );

      Scrollable scrollableIn(Key key) => tester.widget(
        find.descendant(of: find.byKey(key), matching: find.byType(Scrollable)),
      );
      expect(scrollableIn(_main).controller, same(controller));
      expect(scrollableIn(_side).controller, isNot(same(controller)));
    });
  });
}
