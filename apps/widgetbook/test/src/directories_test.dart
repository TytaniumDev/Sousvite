import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite_widgetbook/src/directories.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  group('directories', () {
    final components = WidgetbookRoot(children: directories)
        .findAll((node) => node is WidgetbookComponent)
        .map((node) => node.name);

    test('lists each design_system component once', () {
      // DESIGN_SYSTEM.md §9.2 has 26 components. When you add one to
      // design_system, add its use cases here too.
      expect(components, hasLength(26));
      expect(components.toSet(), hasLength(components.length));
    });
  });
}
