import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:units/units.dart';

import '../../helpers/helpers.dart';

void main() {
  /// The split of "2 cups flour, sifted", or of plain "flour" when
  /// [allParts] is false.
  IngredientSplitPreview preview({
    bool allParts = true,
    ValueChanged<IngredientPart>? onEdit,
  }) => IngredientSplitPreview(
    quantity: allParts ? Quantity(2) : null,
    unit: allParts ? 'cups' : null,
    name: 'flour',
    preparation: allParts ? 'sifted' : null,
    amountLabel: 'Amount',
    nameLabel: 'Ingredient',
    preparationLabel: 'Preparation',
    onEdit: onEdit,
  );

  group(IngredientSplitPreview, () {
    testWidgets('shows each part with its spoken label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpDesignSystem(preview(onEdit: (_) {}));

      expect(find.text('2\u00A0cups'), findsOneWidget);
      expect(find.text('flour'), findsOneWidget);
      expect(find.text('sifted'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Amount, 2\u00A0cups')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('Ingredient, flour')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('Preparation, sifted')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('leaves out parts the parser did not find', (tester) async {
      await tester.pumpDesignSystem(preview(allParts: false));

      expect(find.byType(ActionChip), findsOneWidget);
      expect(find.text('flour'), findsOneWidget);
    });

    testWidgets('reports the tapped part', (tester) async {
      final edited = <IngredientPart>[];
      await tester.pumpDesignSystem(preview(onEdit: edited.add));

      await tester.tap(find.text('2\u00A0cups'));
      await tester.tap(find.text('flour'));
      await tester.tap(find.text('sifted'));
      expect(edited, IngredientPart.values);
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await tester.expectMeetsGuidelines(preview(onEdit: (_) {}));
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'ingredient_split_preview',
      width: 280,
      scenarios: {
        'all parts': preview(onEdit: (_) {}),
        'name only': preview(allParts: false, onEdit: (_) {}),
      },
    );
  });
}
