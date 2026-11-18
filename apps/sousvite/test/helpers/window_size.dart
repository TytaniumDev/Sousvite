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
