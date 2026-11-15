import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite_widgetbook/src/helpers/interactive.dart';

void main() {
  group('Interactive', () {
    Widget counter(int initialValue) => Directionality(
      textDirection: .ltr,
      child: Interactive(
        initialValue: initialValue,
        builder: (context, value, onChanged) => GestureDetector(
          onTap: () => onChanged(value + 1),
          child: Text('$value'),
        ),
      ),
    );

    testWidgets('keeps the value its component changes', (tester) async {
      await tester.pumpWidget(counter(1));
      await tester.tap(find.text('1'));
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('follows a new initial value', (tester) async {
      await tester.pumpWidget(counter(1));
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.pumpWidget(counter(5));

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('keeps its value when rebuilt with the same initial value', (
      tester,
    ) async {
      await tester.pumpWidget(counter(1));
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.pumpWidget(counter(1));

      expect(find.text('2'), findsOneWidget);
    });
  });
}
