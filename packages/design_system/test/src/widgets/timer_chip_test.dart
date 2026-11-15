import 'package:clock/clock.dart';
import 'package:design_system/design_system.dart';
import 'package:design_system/src/widgets/timer_chip.dart' show formatCountdown;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  const fiveMinutes = Duration(minutes: 5);

  TimerChip chip({
    DateTime? startedAt,
    VoidCallback? onStart,
    VoidCallback? onStop,
  }) => TimerChip(
    label: '5 min',
    duration: fiveMinutes,
    doneLabel: 'Done',
    startedAt: startedAt,
    onStart: onStart ?? () {},
    onStop: onStop,
  );

  group(TimerChip, () {
    testWidgets('starts when the idle chip is tapped', (tester) async {
      var started = 0;
      await tester.pumpDesignSystem(chip(onStart: () => started++));

      expect(find.text('5 min'), findsOneWidget);
      await tester.tap(find.byType(TimerChip));
      expect(started, 1);
    });

    testWidgets('counts down once a second, then shows done', (tester) async {
      final startedAt = clock.now();
      var stopped = 0;
      await tester.pumpDesignSystem(
        chip(startedAt: startedAt, onStop: () => stopped++),
      );
      expect(find.text('5:00'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('4:59'), findsOneWidget);

      await tester.pump(const Duration(minutes: 4, seconds: 58));
      expect(find.text('0:01'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Done'), findsOneWidget);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TimerChip));
      expect(stopped, 1);
    });

    testWidgets('picks up a timer that started earlier', (tester) async {
      await tester.pumpDesignSystem(
        chip(startedAt: clock.now().subtract(const Duration(minutes: 2))),
      );
      expect(find.text('3:00'), findsOneWidget);

      await tester.pumpDesignSystem(
        chip(startedAt: clock.now().subtract(const Duration(hours: 1))),
      );
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('goes back to idle when the timer is cleared', (tester) async {
      await tester.pumpDesignSystem(chip(startedAt: clock.now()));
      expect(find.text('5:00'), findsOneWidget);

      await tester.pumpDesignSystem(chip());
      expect(find.text('5 min'), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
      expect(find.text('5 min'), findsOneWidget);
    });

    testWidgets('ticking never rebuilds the parent', (tester) async {
      var parentBuilds = 0;
      final startedAt = clock.now();
      await tester.pumpDesignSystem(
        Builder(
          builder: (context) {
            parentBuilds++;
            return chip(startedAt: startedAt);
          },
        ),
      );
      await tester.pump(const Duration(seconds: 30));

      expect(find.text('4:30'), findsOneWidget);
      expect(parentBuilds, 1);
    });

    testWidgets('does not pulse when motion is reduced', (tester) async {
      await tester.pumpDesignSystem(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: chip(startedAt: clock.now()),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(TimerChip),
          matching: find.byType(ScaleTransition),
        ),
        findsNothing,
      );
    });

    test('formats countdowns, rounding up to the second', () {
      expect(formatCountdown(const Duration(seconds: 65)), '1:05');
      expect(formatCountdown(const Duration(milliseconds: 500)), '0:01');
      expect(
        formatCountdown(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03',
      );
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      await tester.expectMeetsGuidelines(chip());
      await tester.expectMeetsGuidelines(
        chip(startedAt: clock.now(), onStop: () {}),
      );
    });

    designSystemGoldenTest(
      'renders in every variant',
      fileName: 'timer_chip',
      width: 200,
      pumpBeforeTest: (tester) => tester.pump(),
      scenarios: {
        'idle': chip(),
        // Scenarios are built when the test is declared, so read the clock
        // in a builder, inside the test's fake time. Starting half a second
        // into a second keeps the countdown at 4:30 however the frame lands.
        'running': Builder(
          builder: (context) => chip(
            startedAt: clock.now().subtract(
              const Duration(seconds: 30, milliseconds: 500),
            ),
            onStop: () {},
          ),
        ),
        'done': chip(startedAt: DateTime(2000), onStop: () {}),
      },
    );
  });
}
