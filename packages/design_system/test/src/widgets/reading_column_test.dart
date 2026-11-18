import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group(ReadingColumn, () {
    test('adds no insets when the space is narrower than the column', () {
      expect(ReadingColumn.insetsFor(360), EdgeInsets.zero);
      expect(
        ReadingColumn.insetsFor(ReadingColumn.readingWidth),
        EdgeInsets.zero,
      );
    });

    test('centers the column in wider space', () {
      expect(
        ReadingColumn.insetsFor(1000),
        const EdgeInsets.symmetric(horizontal: 140),
      );
      expect(
        ReadingColumn.insetsFor(1600, maxWidth: ReadingColumn.twoPaneWidth),
        const EdgeInsets.symmetric(horizontal: 200),
      );
    });

    testWidgets('gives a scroll view the insets for its own width', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 780,
              child: ReadingColumn(
                builder: (context, insets) => ListView(
                  padding: insets,
                  children: const [SizedBox(key: Key('row'), height: 48)],
                ),
              ),
            ),
          ),
        ),
      );

      final list = tester.getRect(find.byType(ListView));
      final row = tester.getRect(find.byKey(const Key('row')));
      expect(list.width, 780);
      expect(row.width, ReadingColumn.readingWidth);
      expect(row.center.dx, list.center.dx);
    });
  });
}
