import 'package:design_system/design_system.dart';
import 'package:design_system/src/widgets/state_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  ErrorState errorState({VoidCallback? onRetry}) => ErrorState(
    title: "Couldn't load this recipe",
    message: 'Check your connection and try again.',
    retryLabel: 'Try again',
    onRetry: onRetry ?? () {},
  );

  group(ErrorState, () {
    testWidgets('says what went wrong with an error icon', (tester) async {
      await tester.pumpDesignSystem(errorState());

      final message = tester.widget<StateMessage>(find.byType(StateMessage));
      expect(message.icon, Symbols.error_rounded);
      expect(message.iconColor, AppColorSchemes.light.error);
      expect(find.text("Couldn't load this recipe"), findsOneWidget);
      expect(find.text('Check your connection and try again.'), findsOneWidget);
    });

    testWidgets('retries when the button is pressed', (tester) async {
      var retries = 0;
      await tester.pumpDesignSystem(errorState(onRetry: () => retries++));

      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      expect(retries, 1);
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      // The thin 14 dp message fools Flutter's pixel sampling; its pair,
      // on-surface-variant on surface, is checked in contrast_test.dart.
      await tester.expectMeetsGuidelines(errorState(), textContrast: false);
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'error_state',
      width: 320,
      scenarios: {'error': errorState()},
    );
  });
}
