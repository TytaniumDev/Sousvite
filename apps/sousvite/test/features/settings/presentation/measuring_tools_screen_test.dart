import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/settings/application/measuring_tools.dart';
import 'package:sousvite/features/settings/presentation/measuring_tools_screen.dart';

import '../../../helpers/helpers.dart';
import '../fakes.dart';

void main() {
  MeasuringTool catalogTool(Unit unit, Quantity capacity) => [
    ...measuringCups,
    ...measuringSpoons,
  ].singleWhere((tool) => tool.unit == unit && tool.capacity == capacity);

  final thirdCup = catalogTool(Unit.cup, Quantity(1, 3));
  final eighthCup = catalogTool(Unit.cup, Quantity(1, 8));
  final halfTablespoon = catalogTool(Unit.tablespoon, Quantity(1, 2));

  Future<void> pumpScreen(
    WidgetTester tester,
    FakeMeasuringToolRepository repository,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      const MeasuringToolsScreen(),
      overrides: [
        measuringToolRepositoryProvider.overrideWithValue(repository),
      ],
    );
    await tester.pump();
  }

  bool isOn(WidgetTester tester, MeasuringTool tool) => tester
      .widget<SwitchListTile>(
        find.descendant(
          of: find.byKey(ValueKey(tool.id)),
          matching: find.byType(SwitchListTile),
        ),
      )
      .value;

  group(MeasuringToolsScreen, () {
    testWidgets('names tools the way cooks do', (tester) async {
      await pumpScreen(tester, FakeMeasuringToolRepository());

      expect(find.text('1 cup'), findsOneWidget);
      expect(find.text('⅔ cup'), findsOneWidget);
      expect(find.text('½ Tbsp'), findsOneWidget);
      expect(find.text('¼ tsp'), findsOneWidget);
    });

    testWidgets('shows the default set until the user changes it', (
      tester,
    ) async {
      await pumpScreen(tester, FakeMeasuringToolRepository());

      expect(isOn(tester, thirdCup), isTrue);
      expect(isOn(tester, eighthCup), isFalse);
    });

    testWidgets('turning a tool on rebuilds only its row', (tester) async {
      final repository = FakeMeasuringToolRepository([
        thirdCup,
        halfTablespoon,
      ]);
      await pumpScreen(tester, repository);
      final builds = BuildCounter.start();

      await tester.tap(find.text('⅛ cup'));
      await tester.pump();

      expect(repository.tools, [thirdCup, halfTablespoon, eighthCup]);
      expect(isOn(tester, eighthCup), isTrue);
      expect(builds.ofKey(ValueKey(eighthCup.id)), 1);
      expect(builds.ofKey(ValueKey(thirdCup.id)), 0);
      expect(builds.of<MeasuringToolsScreen>(), 0);
    });

    testWidgets('keeps the last tool on', (tester) async {
      final repository = FakeMeasuringToolRepository([thirdCup]);
      await pumpScreen(tester, repository);

      expect(find.text('Keep at least one'), findsOneWidget);
      await tester.tap(find.text('⅓ cup'));
      await tester.pump();

      expect(repository.tools, [thirdCup]);
    });
  });
}
