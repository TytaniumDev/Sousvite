import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

extension WindowSize on WidgetTester {
  /// Makes the test window [width] dp wide until the test ends, to check
  /// layouts on tablets and the web (DESIGN_SYSTEM.md §6.3).
  void setWindowWidth(double width, {double height = 1000}) {
    view
      ..physicalSize = Size(width, height)
      ..devicePixelRatio = 1;
    addTearDown(view.reset);
  }

  /// Expects everything [finder] finds to sit inside a column at most
  /// [maxWidth] wide, centered in the window.
  void expectInCenteredColumn(Finder finder, double maxWidth) {
    final window = view.physicalSize.width / view.devicePixelRatio;
    final inset = (window - maxWidth) / 2;
    expect(finder, findsWidgets);
    for (final element in finder.evaluate()) {
      final box = element.renderObject! as RenderBox;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      expect(rect.left, greaterThanOrEqualTo(inset), reason: '$element');
      expect(rect.right, lessThanOrEqualTo(window - inset), reason: '$element');
    }
  }
}

/// Runs [body] once in a window of each size class (DESIGN_SYSTEM.md §6.3),
/// so a screen is checked on phones, tablets, and desktops. A layout that
/// overflows fails the test.
void testWidgetsAtEverySize(
  String description,
  Future<void> Function(WidgetTester tester, WindowSizeClass sizeClass) body,
) {
  for (final sizeClass in WindowSizeClass.values) {
    testWidgets('$description (${sizeClass.name})', (tester) async {
      tester.setWindowWidth(sampleWidthOf(sizeClass));
      await body(tester, sizeClass);
    });
  }
}

/// A typical window width in [sizeClass]: a phone, a small tablet, a
/// tablet in landscape, a laptop, and a desktop browser.
double sampleWidthOf(WindowSizeClass sizeClass) => switch (sizeClass) {
  .compact => 400,
  .medium => 700,
  .expanded => 1000,
  .large => 1400,
  .extraLarge => 1800,
};
