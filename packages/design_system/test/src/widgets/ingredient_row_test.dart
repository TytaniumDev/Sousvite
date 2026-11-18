import 'package:design_system/design_system.dart';
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
    });

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
