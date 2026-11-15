import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite_widgetbook/src/helpers/preview.dart';

void main() {
  group(Preview, () {
    const box = SizedBox(key: Key('box'), width: 500, height: 10);

    testWidgets('limits the width to a phone by default', (tester) async {
      await tester.pumpWidget(const Preview(child: box));

      expect(tester.getSize(find.byKey(const Key('box'))).width, 360);
    });

    testWidgets('lets the child size itself without a limit', (tester) async {
      await tester.pumpWidget(const Preview(maxWidth: null, child: box));

      expect(tester.getSize(find.byKey(const Key('box'))).width, 500);
    });
  });
}
