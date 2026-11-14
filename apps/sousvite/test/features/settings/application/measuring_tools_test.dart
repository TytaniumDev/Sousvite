import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/settings/application/measuring_tools.dart';

import '../fakes.dart';

void main() {
  MeasuringTool find(Unit unit, Quantity capacity) => [
    ...measuringCups,
    ...measuringSpoons,
  ].singleWhere((tool) => tool.unit == unit && tool.capacity == capacity);

  final eighthCup = find(Unit.cup, Quantity(1, 8));
  final thirdCup = find(Unit.cup, Quantity(1, 3));

  ProviderContainer containerWith(FakeMeasuringToolRepository repository) =>
      ProviderContainer.test(
        overrides: [
          measuringToolRepositoryProvider.overrideWithValue(repository),
        ],
      );

  group('measuring tool catalog', () {
    test("defaults to Tyler's set: everything but the eighths", () {
      expect(defaultMeasuringTools, hasLength(11));
      expect(defaultMeasuringTools, isNot(contains(eighthCup)));
      expect(
        defaultMeasuringTools,
        isNot(contains(find(Unit.teaspoon, Quantity(1, 8)))),
      );
    });

    test('gives every tool a stable, unique id', () {
      final ids = [...measuringCups, ...measuringSpoons].map((t) => t.id);

      expect(ids.toSet(), hasLength(ids.length));
      expect(
        find(Unit.cup, Quantity(3, 4)).id,
        const MeasuringToolId('cup-3-4'),
      );
    });
  });

  group('ownedMeasuringToolsProvider', () {
    test('is the default set until the user changes it', () async {
      final container = containerWith(FakeMeasuringToolRepository())
        ..listen(ownedMeasuringToolsProvider, (_, _) {});

      expect(
        await container.read(ownedMeasuringToolsProvider.future),
        defaultMeasuringTools,
      );
    });

    test('is what the user saved', () async {
      final container = containerWith(FakeMeasuringToolRepository([thirdCup]))
        ..listen(ownedMeasuringToolsProvider, (_, _) {});

      expect(await container.read(ownedMeasuringToolsProvider.future), [
        thirdCup,
      ]);
    });
  });

  group(MeasuringToolsController, () {
    test('the first change keeps the rest of the default set', () async {
      final repository = FakeMeasuringToolRepository();
      final container = containerWith(repository);

      await container
          .read(measuringToolsControllerProvider.notifier)
          .setOwned(thirdCup, owned: false);

      expect(repository.tools, [
        for (final tool in defaultMeasuringTools)
          if (tool != thirdCup) tool,
      ]);
    });

    test('later changes add or remove one tool', () async {
      final repository = FakeMeasuringToolRepository([thirdCup]);
      final controller = containerWith(repository)
          .read(measuringToolsControllerProvider.notifier);

      await controller.setOwned(eighthCup, owned: true);
      expect(repository.tools, [thirdCup, eighthCup]);

      await controller.setOwned(thirdCup, owned: false);
      expect(repository.tools, [eighthCup]);
    });
  });
}
