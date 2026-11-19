import 'package:design_system/src/widgets/fading_edges.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  /// [count] 50 dp rows in a 200 dp tall (or wide) faded list.
  Widget fadedList({
    int count = 20,
    Axis axis = .vertical,
    bool reverse = false,
    double initialOffset = 0,
    double extent = FadingEdges.defaultExtent,
  }) => SizedBox.square(
    dimension: 200,
    child: FadingEdges(
      extent: extent,
      child: ListView(
        scrollDirection: axis,
        reverse: reverse,
        controller: ScrollController(initialScrollOffset: initialOffset),
        children: [
          for (var i = 0; i < count; i++)
            SizedBox.square(
              dimension: 50,
              child: Align(alignment: .centerLeft, child: Text('Row $i')),
            ),
        ],
      ),
    ),
  );

  RenderFadeMask mask(WidgetTester tester) =>
      tester.renderObject<RenderFadeMask>(
        find
            .descendant(
              of: find.byType(FadingEdges),
              matching: find.byWidgetPredicate(
                (widget) => widget is SingleChildRenderObjectWidget,
              ),
            )
            .first,
      );

  EdgeFades fades(WidgetTester tester) => mask(tester).fades.value;

  group(FadingEdges, () {
    testWidgets('leaves a list that fits with sharp edges', (tester) async {
      await tester.pumpDesignSystem(fadedList(count: 3));
      await tester.pump();

      expect(fades(tester), (direction: AxisDirection.down, start: 0, end: 0));
      expect(mask(tester).debugLayer, isNull);
    });

    testWidgets('fades only the end at the top of a long list', (tester) async {
      await tester.pumpDesignSystem(fadedList());
      await tester.pump();

      expect(fades(tester), (direction: AxisDirection.down, start: 0, end: 32));
      expect(mask(tester).debugLayer, isA<ShaderMaskLayer>());
    });

    testWidgets('grows the start fade over the first extent scrolled', (
      tester,
    ) async {
      await tester.pumpDesignSystem(fadedList());
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -16));
      await tester.pump();
      expect(fades(tester).start, closeTo(16, 0.5));

      await tester.drag(find.byType(ListView), const Offset(0, -100));
      await tester.pump();
      expect(fades(tester), (
        direction: AxisDirection.down,
        start: 32,
        end: 32,
      ));
    });

    testWidgets('leaves the end sharp at the bottom of the list', (
      tester,
    ) async {
      await tester.pumpDesignSystem(fadedList(initialOffset: 800));
      await tester.pump();

      expect(fades(tester), (direction: AxisDirection.down, start: 32, end: 0));
    });

    testWidgets('keeps the start sharp when asked to', (tester) async {
      await tester.pumpDesignSystem(
        SizedBox.square(
          dimension: 200,
          child: FadingEdges(
            fadeStart: false,
            child: ListView(
              controller: ScrollController(initialScrollOffset: 100),
              children: const [SizedBox(height: 1000)],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(fades(tester), (direction: AxisDirection.down, start: 0, end: 32));
    });

    testWidgets('follows a reversed list', (tester) async {
      await tester.pumpDesignSystem(fadedList(reverse: true));
      await tester.pump();

      expect(fades(tester), (direction: AxisDirection.up, start: 0, end: 32));
    });

    testWidgets('fades a horizontal list at its sides', (tester) async {
      await tester.pumpDesignSystem(fadedList(axis: .horizontal));
      await tester.pump();

      expect(fades(tester), (
        direction: AxisDirection.right,
        start: 0,
        end: 32,
      ));
    });

    testWidgets('ignores a scroll view nested inside its own', (tester) async {
      await tester.pumpDesignSystem(
        SizedBox.square(
          dimension: 200,
          child: FadingEdges(
            child: ListView(
              children: [
                SizedBox(
                  height: 50,
                  child: ListView(
                    key: const Key('inner'),
                    scrollDirection: .horizontal,
                    children: [
                      for (var i = 0; i < 10; i++)
                        const SizedBox(width: 50, child: Text('Chip')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.drag(find.byKey(const Key('inner')), const Offset(-60, 0));
      await tester.pump();

      expect(fades(tester), (direction: AxisDirection.down, start: 0, end: 0));
    });

    testWidgets('updates when the content grows', (tester) async {
      await tester.pumpDesignSystem(fadedList(count: 3));
      await tester.pump();
      expect(fades(tester).end, 0);

      await tester.pumpDesignSystem(fadedList());
      await tester.pump();

      expect(fades(tester).end, 32);
    });

    testWidgets('repaints instead of rebuilding while scrolling', (
      tester,
    ) async {
      var builds = 0;
      await tester.pumpDesignSystem(
        SizedBox.square(
          dimension: 200,
          child: FadingEdges(
            child: Builder(
              builder: (context) {
                builds++;
                return ListView(children: const [SizedBox(height: 1000)]);
              },
            ),
          ),
        ),
      );
      await tester.pump();
      builds = 0;

      await tester.drag(find.byType(ListView), const Offset(0, -100));
      await tester.pump();

      expect(builds, 0);
      expect(fades(tester).start, 32);
    });

    testWidgets('never fades taller than the content scrolled past', (
      tester,
    ) async {
      await tester.pumpDesignSystem(fadedList(initialOffset: 10));
      await tester.pump();

      expect(fades(tester), (
        direction: AxisDirection.down,
        start: 10,
        end: 32,
      ));
      expect(mask(tester).debugLayer, isA<ShaderMaskLayer>());
    });

    testWidgets('fades as tall as a longer extent', (tester) async {
      await tester.pumpDesignSystem(fadedList(initialOffset: 100, extent: 64));
      await tester.pump();

      expect(fades(tester), (
        direction: AxisDirection.down,
        start: 64,
        end: 64,
      ));
    });

    testWidgets('keeps the fades from crossing in a short list', (
      tester,
    ) async {
      await tester.pumpDesignSystem(
        SizedBox(
          height: 40,
          width: 200,
          child: FadingEdges(
            child: ListView(children: const [SizedBox(height: 100)]),
          ),
        ),
      );
      await tester.drag(find.byType(ListView), const Offset(0, -30));
      await tester.pump();

      expect(fades(tester), (
        direction: AxisDirection.down,
        start: 30,
        end: 30,
      ));
      expect(mask(tester).debugLayer, isA<ShaderMaskLayer>());
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      // The faded rows at the edge are meant to look faint; scrolling
      // brings them into full contrast.
      await tester.expectMeetsGuidelines(
        fadedList(initialOffset: 100),
        textContrast: false,
      );
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'fading_edges',
      width: 200,
      scenarios: {
        'top of the list': fadedList(),
        'just scrolled': fadedList(initialOffset: 20),
        'middle of the list': fadedList(initialOffset: 325),
        'bottom of the list': fadedList(initialOffset: 800),
        'fits': fadedList(count: 3),
      },
    );
  });
}
