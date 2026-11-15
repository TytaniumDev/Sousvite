import 'package:design_system/design_system.dart';
import 'package:design_system/src/widgets/state_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  EmptyState emptyState({Widget? action}) => EmptyState(
    icon: Symbols.menu_book_rounded,
    title: 'No recipes yet',
    message: 'Paste a link or write your own.',
    action: action,
  );

  group(EmptyState, () {
    testWidgets('shows what the space is for in a quiet color', (tester) async {
      await tester.pumpDesignSystem(emptyState());

      final message = tester.widget<StateMessage>(find.byType(StateMessage));
      expect(message.icon, Symbols.menu_book_rounded);
      expect(message.iconColor, AppColorSchemes.light.onSurfaceVariant);
      expect(find.text('No recipes yet'), findsOneWidget);
      expect(find.text('Paste a link or write your own.'), findsOneWidget);
    });

    testWidgets('shows the action that fills the space', (tester) async {
      var pressed = 0;
      await tester.pumpDesignSystem(
        emptyState(
          action: FilledButton(
            onPressed: () => pressed++,
            child: const Text('Add a recipe'),
          ),
        ),
      );

      await tester.tap(find.text('Add a recipe'));
      expect(pressed, 1);
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      // The thin 14 dp message fools Flutter's pixel sampling; its pair,
      // on-surface-variant on surface, is checked in contrast_test.dart.
      await tester.expectMeetsGuidelines(
        emptyState(
          action: FilledButton(
            onPressed: () {},
            child: const Text('Add a recipe'),
          ),
        ),
        textContrast: false,
      );
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'empty_state',
      width: 320,
      scenarios: {
        'with action': emptyState(
          action: FilledButton(
            onPressed: () {},
            child: const Text('Add a recipe'),
          ),
        ),
        'message only': emptyState(),
      },
    );
  });
}
