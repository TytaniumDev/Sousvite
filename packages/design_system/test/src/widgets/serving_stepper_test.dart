import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:units/units.dart';

import '../../helpers/helpers.dart';

void main() {
  ServingStepper stepper(
    Quantity servings, {
    ValueChanged<Quantity>? onChanged,
    Quantity? max,
  }) => ServingStepper(
    servings: servings,
    unit: 'servings',
    onChanged: onChanged ?? (_) {},
    decreaseLabel: 'Fewer servings',
    increaseLabel: 'More servings',
    max: max,
  );

  group(ServingStepper, () {
    testWidgets('shows the servings with their unit', (tester) async {
      await tester.pumpDesignSystem(stepper(Quantity(5, 2)));

      expect(find.text('2 ½ servings'), findsOneWidget);
    });

    testWidgets('steps by whole servings', (tester) async {
      final changes = <Quantity>[];
      await tester.pumpDesignSystem(
        stepper(Quantity(4), onChanged: changes.add),
      );
      await tester.tap(find.byTooltip('Fewer servings'));
      await tester.tap(find.byTooltip('More servings'));
      expect(changes, [Quantity(3), Quantity(5)]);

      changes.clear();
      await tester.pumpDesignSystem(
        stepper(Quantity(5, 2), onChanged: changes.add),
      );
      await tester.tap(find.byTooltip('Fewer servings'));
      await tester.tap(find.byTooltip('More servings'));
      expect(changes, [Quantity(2), Quantity(3)]);
    });

    testWidgets('stops at the minimum and maximum', (tester) async {
      final changes = <Quantity>[];
      await tester.pumpDesignSystem(
        stepper(Quantity.one, onChanged: changes.add),
      );
      await tester.tap(find.byTooltip('Fewer servings'));
      expect(changes, isEmpty);

      await tester.pumpDesignSystem(
        stepper(Quantity(8), onChanged: changes.add, max: Quantity(8)),
      );
      await tester.tap(find.byTooltip('More servings'));
      expect(changes, isEmpty);
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await tester.expectMeetsGuidelines(stepper(Quantity(4)));
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'serving_stepper',
      scenarios: {
        'whole': stepper(Quantity(4)),
        'fraction': stepper(Quantity(5, 2)),
        'at minimum': stepper(Quantity.one),
      },
    );
  });
}
