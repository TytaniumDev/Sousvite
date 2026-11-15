import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:units/units.dart';

import '../../helpers/helpers.dart';

void main() {
  final twoAndAQuarter = Quantity(9, 4);

  GroceryItemRow row({
    bool checked = false,
    ValueChanged<bool>? onChanged,
    Quantity? quantity,
    String? unit = 'cups',
    String? sourcesLabel = 'Chili, Cornbread',
    String name = 'flour',
  }) => GroceryItemRow(
    name: name,
    checked: checked,
    onChanged: onChanged ?? (_) {},
    quantity: quantity,
    unit: unit,
    sourcesLabel: sourcesLabel,
  );

  TextStyle styleOf(WidgetTester tester, String text) => tester
      .widget<RichText>(
        find.descendant(of: find.text(text), matching: find.byType(RichText)),
      )
      .text
      .style!;

  group(GroceryItemRow, () {
    testWidgets('shows the name, amount and where it came from', (
      tester,
    ) async {
      await tester.pumpDesignSystem(row(quantity: twoAndAQuarter));

      expect(find.text('flour'), findsOneWidget);
      expect(find.text('2 ¼ cups'), findsOneWidget);
      expect(find.text('Chili, Cornbread'), findsOneWidget);
    });

    testWidgets('leaves out the amount and sources when there are none', (
      tester,
    ) async {
      await tester.pumpDesignSystem(row(sourcesLabel: null, name: 'salt'));

      expect(find.byType(AmountText), findsNothing);
      expect(find.text('salt'), findsOneWidget);
    });

    testWidgets('toggles when tapped anywhere on the row', (tester) async {
      final changes = <bool>[];
      await tester.pumpDesignSystem(row(onChanged: changes.add));

      await tester.tap(find.text('flour'));
      await tester.tap(find.byType(Checkbox));
      expect(changes, [true, true]);
    });

    testWidgets('unchecks a checked item', (tester) async {
      final changes = <bool>[];
      await tester.pumpDesignSystem(row(checked: true, onChanged: changes.add));

      await tester.tap(find.byType(Checkbox));
      expect(changes, [false]);
    });

    testWidgets('strikes through a checked item but not its sources', (
      tester,
    ) async {
      await tester.pumpDesignSystem(
        row(checked: true, quantity: twoAndAQuarter),
      );
      await tester.pumpAndSettle();

      expect(styleOf(tester, 'flour').decoration, TextDecoration.lineThrough);
      expect(
        styleOf(tester, 'flour').color,
        AppColorSchemes.light.onSurfaceVariant,
      );
      expect(
        styleOf(tester, '2 ¼ cups').decoration,
        TextDecoration.lineThrough,
      );
      expect(
        styleOf(tester, 'Chili, Cornbread').decoration,
        TextDecoration.none,
      );
    });

    testWidgets('moves the amount under the name for large text', (
      tester,
    ) async {
      await tester.pumpDesignSystem(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: row(quantity: twoAndAQuarter),
          ),
        ),
      );

      final name = tester.getRect(find.text('flour'));
      final amount = tester.getRect(find.byType(AmountText));
      expect(amount.top, greaterThanOrEqualTo(name.bottom));
      expect(amount.left, name.left);
    });

    testWidgets('keeps the amount at the end at normal size', (tester) async {
      await tester.pumpDesignSystem(row(quantity: twoAndAQuarter));

      final name = tester.getRect(find.text('flour'));
      final amount = tester.getRect(find.byType(AmountText));
      expect(amount.left, greaterThan(name.right));
    });

    testWidgets('is at least 56 dp tall', (tester) async {
      await tester.pumpDesignSystem(row(sourcesLabel: null));

      expect(
        tester.getSize(find.byType(GroceryItemRow)).height,
        greaterThanOrEqualTo(GroceryItemRow.minHeight),
      );
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await tester.expectMeetsGuidelines(row(quantity: twoAndAQuarter));
      await tester.expectMeetsGuidelines(
        row(checked: true, quantity: twoAndAQuarter),
      );
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'grocery_item_row',
      width: 360,
      scenarios: {
        'with amount and sources': row(quantity: twoAndAQuarter),
        'checked': row(checked: true, quantity: twoAndAQuarter),
        'by hand, no amount': row(sourcesLabel: null, name: 'salt'),
        'long name': row(
          quantity: Quantity(3),
          unit: 'tablespoons',
          name: 'extra virgin olive oil, the good one',
        ),
      },
    );
  });
}
