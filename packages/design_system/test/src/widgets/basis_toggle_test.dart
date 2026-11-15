import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  BasisToggle toggle({
    NutritionBasis basis = NutritionBasis.perServing,
    ValueChanged<NutritionBasis>? onChanged,
  }) => BasisToggle(
    basis: basis,
    onChanged: onChanged ?? (_) {},
    perServingLabel: 'Per serving',
    batchLabel: 'Per batch',
  );

  group(BasisToggle, () {
    testWidgets('shows both choices with the current one selected', (
      tester,
    ) async {
      await tester.pumpDesignSystem(toggle());

      final button = tester.widget<SegmentedButton<NutritionBasis>>(
        find.byType(SegmentedButton<NutritionBasis>),
      );
      expect(button.selected, {NutritionBasis.perServing});
      expect(find.text('Per serving'), findsOneWidget);
      expect(find.text('Per batch'), findsOneWidget);
    });

    testWidgets('reports the basis the user picks', (tester) async {
      final picked = <NutritionBasis>[];
      await tester.pumpDesignSystem(toggle(onChanged: picked.add));

      await tester.tap(find.text('Per batch'));
      expect(picked, [NutritionBasis.batch]);
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await tester.expectMeetsGuidelines(toggle());
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'basis_toggle',
      scenarios: {
        'per serving': toggle(),
        'per batch': toggle(basis: .batch),
      },
    );
  });
}
