import 'package:design_system/src/widgets/tappable_amount.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  group(TappableAmount, () {
    testWidgets('pads a plain amount at its sides with no ink', (tester) async {
      await tester.pumpDesignSystem(
        const Center(
          child: TappableAmount(onTap: null, tapLabel: null, child: Text('2')),
        ),
      );

      expect(find.byType(InkWell), findsNothing);
      expect(
        tester.getSize(find.byType(TappableAmount)).width,
        tester.getSize(find.text('2')).width + 2 * TappableAmount.padding,
      );
    });

    testWidgets('calls onTap and offers it as a screen reader action', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpDesignSystem(
        Center(
          child: TappableAmount(
            onTap: () => taps++,
            tapLabel: 'Show amounts by recipe',
            child: const Text('2'),
          ),
        ),
      );

      await tester.tap(find.text('2'));
      expect(taps, 1);

      final node = tester.getSemantics(find.byType(TappableAmount));
      final action = node.getSemanticsData().customSemanticsActionIds!.single;
      expect(
        CustomSemanticsAction.getAction(action)?.label,
        'Show amounts by recipe',
      );
      handle.dispose();
    });
  });
}
