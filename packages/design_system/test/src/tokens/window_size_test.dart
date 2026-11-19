import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group(WindowSizeClass, () {
    test('maps widths to size classes', () {
      expect(WindowSizeClass.fromWidth(599), WindowSizeClass.compact);
      expect(WindowSizeClass.fromWidth(600), WindowSizeClass.medium);
      expect(WindowSizeClass.fromWidth(839), WindowSizeClass.medium);
      expect(WindowSizeClass.fromWidth(840), WindowSizeClass.expanded);
      expect(WindowSizeClass.fromWidth(1199), WindowSizeClass.expanded);
      expect(WindowSizeClass.fromWidth(1200), WindowSizeClass.large);
      expect(WindowSizeClass.fromWidth(1599), WindowSizeClass.large);
      expect(WindowSizeClass.fromWidth(1600), WindowSizeClass.extraLarge);
    });

    test('keeps a 16 dp margin on phones and 24 dp on wider windows', () {
      expect(WindowSizeClass.compact.margin, 16);
      for (final sizeClass in WindowSizeClass.values.skip(1)) {
        expect(sizeClass.margin, 24, reason: '$sizeClass');
      }
    });

    test('compares size classes by width', () {
      expect(WindowSizeClass.large.isAtLeast(.expanded), isTrue);
      expect(WindowSizeClass.large.isAtLeast(.large), isTrue);
      expect(WindowSizeClass.large.isAtLeast(.extraLarge), isFalse);
    });

    testWidgets('reads the window width from the context', (tester) async {
      late WindowSizeClass sizeClass;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(700, 800)),
          child: Builder(
            builder: (context) {
              sizeClass = WindowSizeClass.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(sizeClass, WindowSizeClass.medium);
    });
  });
}
