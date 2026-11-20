import 'package:design_system/design_system.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:units/units.dart';

import '../../helpers/helpers.dart';

void main() {
  final readOnly = IngredientRow(
    quantity: Quantity(9, 4),
    unit: 'cups',
    amountSemanticsLabel: 'two and a quarter cups',
    name: 'flour',
    preparation: 'sifted',
  );

  group(IngredientRow, () {
    testWidgets('shows amount, name, and preparation', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpDesignSystem(readOnly);

      expect(find.text('2 ¼\u00A0cups'), findsOneWidget);
      expect(find.text('flour, sifted'), findsOneWidget);
      expect(find.bySemanticsLabel('two and a quarter cups'), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);
      handle.dispose();
    });

    testWidgets('leaves the amount column empty when there is none', (
      tester,
    ) async {
      await tester.pumpDesignSystem(const IngredientRow(name: 'salt'));

      expect(find.text('salt'), findsOneWidget);
      expect(find.byType(AmountText), findsNothing);
    });

    testWidgets('is compact inside compact density', (tester) async {
      await tester.pumpDesignSystem(readOnly);
      final standard = tester.getSize(find.byType(IngredientRow)).height;

      await tester.pumpDesignSystem(
        Theme(
          data: AppTheme.light().copyWith(visualDensity: VisualDensity.compact),
          child: readOnly,
        ),
      );
      final compact = tester.getSize(find.byType(IngredientRow)).height;

      expect(standard, 48);
      expect(compact, 40);
    });

    testWidgets('a row with a checkbox is 48 dp inside compact density', (
      tester,
    ) async {
      await tester.pumpDesignSystem(
        CompactDensity(
          child: IngredientRow(name: 'eggs', onChanged: (_) {}),
        ),
      );

      expect(tester.getSize(find.byType(IngredientRow)).height, 48);
    });

    testWidgets('shows a guide under the name', (tester) async {
      await tester.pumpDesignSystem(
        const IngredientRow(name: 'salt', guide: Text('Use ½ Tbsp')),
      );

      expect(
        tester.getTopLeft(find.text('Use ½ Tbsp')).dy,
        greaterThan(tester.getBottomLeft(find.text('salt')).dy - 1),
      );
      expect(
        tester.getTopLeft(find.text('Use ½ Tbsp')).dx,
        tester.getTopLeft(find.text('salt')).dx,
      );
    });

    testWidgets('toggles when the row is tapped', (tester) async {
      final changes = <bool>[];
      await tester.pumpDesignSystem(
        IngredientRow(
          name: 'eggs',
          quantity: Quantity(2),
          onChanged: changes.add,
        ),
      );

      expect(tester.getSize(find.byType(IngredientRow)).height, 56);
      await tester.tap(find.text('eggs'));
      await tester.tap(find.byType(Checkbox));
      expect(changes, [true, true]);

      await tester.pumpDesignSystem(
        IngredientRow(name: 'eggs', checked: true, onChanged: changes.add),
      );
      await tester.tap(find.text('eggs'));
      expect(changes.last, isFalse);
    });

    group('with a tappable amount', () {
      IngredientRow tappable({
        required VoidCallback onAmountTap,
        ValueChanged<bool>? onChanged,
      }) => IngredientRow(
        name: 'garlic',
        quantity: Quantity(2),
        unit: 'cloves',
        onChanged: onChanged,
        onAmountTap: onAmountTap,
        amountTapLabel: 'Show as jarred garlic',
      );

      testWidgets('calls onAmountTap and leaves the row unchecked', (
        tester,
      ) async {
        var taps = 0;
        final changes = <bool>[];
        await tester.pumpDesignSystem(
          tappable(onAmountTap: () => taps++, onChanged: changes.add),
        );

        await tester.tap(find.byType(AmountText));
        expect(taps, 1);
        expect(changes, isEmpty);

        await tester.tap(find.text('garlic'));
        expect(taps, 1);
        expect(changes, [true]);
      });

      Finder amountInk() => find.ancestor(
        of: find.byType(AmountText),
        matching: find.byType(InkWell),
      );

      testWidgets('pads the amount evenly inside its ink', (tester) async {
        await tester.pumpDesignSystem(tappable(onAmountTap: () {}));

        final ink = tester.getRect(amountInk());
        final amount = tester.getRect(find.byType(AmountText));
        const padding = IngredientRow.amountPadding;
        expect(amount.left - ink.left, padding);
        expect(ink.right - amount.right, padding);
        expect(amount.top - ink.top, padding);
        expect(ink.bottom - amount.bottom, padding);
      });

      testWidgets('lines up with a plain amount', (tester) async {
        await tester.pumpDesignSystem(
          Column(
            children: [
              tappable(onAmountTap: () {}),
              IngredientRow(name: 'salt', quantity: Quantity(1), unit: 'tsp'),
            ],
          ),
        );

        final amounts = find.byType(AmountText);
        expect(
          tester.getTopLeft(amounts.first).dx,
          tester.getTopLeft(amounts.last).dx,
        );
        expect(
          tester.getTopLeft(find.text('garlic')).dx,
          tester.getTopLeft(find.text('salt')).dx,
        );
      });

      testWidgets('takes taps across 48 dp from a short amount', (
        tester,
      ) async {
        var taps = 0;
        await tester.pumpDesignSystem(
          IngredientRow(
            name: 'garlic cloves',
            quantity: Quantity(2),
            onAmountTap: () => taps++,
            amountTapLabel: 'Show as jarred garlic',
          ),
        );

        final ink = tester.getRect(amountInk());
        expect(ink.width, lessThan(kMinInteractiveDimension));
        await tester.tapAt(
          ink.centerLeft + const Offset(kMinInteractiveDimension - 2, 0),
        );
        expect(taps, 1);
      });

      testWidgets('offers the tap as a screen reader action', (tester) async {
        final handle = tester.ensureSemantics();
        var taps = 0;
        await tester.pumpDesignSystem(
          tappable(onAmountTap: () => taps++, onChanged: (_) {}),
        );

        // The row merges its semantics, so the action is on the row.
        final row = tester.getSemantics(find.byType(IngredientRow));
        final action = row.getSemanticsData().customSemanticsActionIds!.single;
        expect(
          CustomSemanticsAction.getAction(action)?.label,
          'Show as jarred garlic',
        );
        row.owner!.performAction(row.id, SemanticsAction.customAction, action);
        expect(taps, 1);
        handle.dispose();
      });
    });

    testWidgets('strikes through a checked line', (tester) async {
      await tester.pumpDesignSystem(
        IngredientRow(name: 'eggs', checked: true, onChanged: (_) {}),
      );
      await tester.pumpAndSettle();

      final style = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('eggs'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(style.decoration, TextDecoration.lineThrough);
      expect(style.color, AppColorSchemes.light.onSurfaceVariant);
    });

    testWidgets('leaves a selected line as it is', (tester) async {
      await tester.pumpDesignSystem(
        IngredientRow(
          name: 'eggs',
          checked: true,
          checkStyle: IngredientCheckStyle.select,
          onChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      final style = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('eggs'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(style.decoration, isNot(TextDecoration.lineThrough));
      expect(style.color, AppColorSchemes.light.onSurface);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    });

    testWidgets('changes at once when motion is reduced', (tester) async {
      await tester.pumpDesignSystem(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: IngredientRow(name: 'eggs', checked: true, onChanged: (_) {}),
        ),
      );
      final animated = tester.widget<AnimatedDefaultTextStyle>(
        find.descendant(
          of: find.byType(IngredientRow),
          matching: find.byType(AnimatedDefaultTextStyle),
        ),
      );
      expect(animated.duration, Duration.zero);
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await tester.expectMeetsGuidelines(readOnly);
      await tester.expectMeetsGuidelines(
        IngredientRow(
          name: 'butter',
          quantity: Quantity(1, 2),
          unit: 'cup',
          checked: true,
          onChanged: (_) {},
        ),
      );
      await tester.expectMeetsGuidelines(
        IngredientRow(
          name: 'butter',
          quantity: Quantity(2),
          unit: 'Tbsp',
          onAmountTap: () {},
          amountTapLabel: 'Show as jarred garlic',
        ),
      );
    });

    designSystemGoldenTest(
      'lines tappable amounts up with plain ones',
      fileName: 'ingredient_row_amounts',
      width: 320,
      scenarios: {
        'short and long amounts': Column(
          children: [
            IngredientRow(name: 'red onion', quantity: Quantity(1, 2)),
            IngredientRow(
              name: 'garlic cloves',
              quantity: Quantity(2),
              onAmountTap: () {},
              amountTapLabel: 'Show as jarred garlic',
            ),
            IngredientRow(
              name: 'garlic',
              preparation: 'minced',
              quantity: Quantity(2),
              unit: 'tsp',
              onAmountTap: () {},
              amountTapLabel: 'Show as garlic cloves',
            ),
            IngredientRow(
              name: 'brown rice',
              quantity: Quantity(3, 4),
              unit: 'cup',
            ),
          ],
        ),
      },
    );

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'ingredient_row',
      width: 320,
      scenarios: {
        'read-only': readOnly,
        'no amount': const IngredientRow(name: 'salt', preparation: 'to taste'),
        'unchecked': IngredientRow(
          name: 'butter',
          quantity: Quantity(1, 2),
          unit: 'cup',
          preparation: 'softened',
          onChanged: (_) {},
        ),
        'checked': IngredientRow(
          name: 'butter',
          quantity: Quantity(1, 2),
          unit: 'cup',
          preparation: 'softened',
          checked: true,
          onChanged: (_) {},
        ),
        'selected': IngredientRow(
          name: 'butter',
          quantity: Quantity(1, 2),
          unit: 'cup',
          preparation: 'softened',
          checked: true,
          checkStyle: IngredientCheckStyle.select,
          onChanged: (_) {},
        ),
        'with guide': IngredientRow(
          name: 'kosher salt',
          quantity: Quantity(3, 2),
          unit: 'tsp',
          onChanged: (_) {},
          guide: MeasuringGuide(
            label: 'Use',
            tools: [(quantity: Quantity(1, 2), unit: 'Tbsp')],
          ),
        ),
        'compact': CompactDensity(
          child: IngredientRow(
            name: 'butter',
            quantity: Quantity(1, 2),
            unit: 'cup',
            onChanged: (_) {},
          ),
        ),
      },
    );
  });
}
