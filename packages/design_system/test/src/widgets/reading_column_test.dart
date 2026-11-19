import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group(ReadingColumn, () {
    test('adds no insets on a phone', () {
      expect(ReadingColumn.insetsFor(360), EdgeInsets.zero);
    });

    test('keeps the 24 dp window margin on wider windows', () {
      // The content pads itself by 16 dp, so the column adds 8 dp.
      expect(
        ReadingColumn.insetsFor(ReadingColumn.readingWidth),
        const EdgeInsets.symmetric(horizontal: 8),
      );
    });

    test('centers the column in wider space', () {
      expect(
        ReadingColumn.insetsFor(1000),
        const EdgeInsets.symmetric(horizontal: 140),
      );
      expect(
        ReadingColumn.insetsFor(1600, maxWidth: ReadingColumn.formWidth),
        const EdgeInsets.symmetric(horizontal: 600),
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
