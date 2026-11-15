import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/app/providers/repositories.dart';

part 'measuring_tools.g.dart';

MeasuringTool _tool(Unit unit, int numerator, [int denominator = 1]) =>
    MeasuringTool(
      // Fixed ids, so the same tool picked on two devices syncs as one.
      id: MeasuringToolId('${unit.name}-$numerator-$denominator'),
      capacity: Quantity(numerator, denominator),
      unit: unit,
    );

/// The measuring cups settings offers, largest first.
final List<MeasuringTool> measuringCups = List.unmodifiable([
  _tool(.cup, 1),
  _tool(.cup, 3, 4),
  _tool(.cup, 2, 3),
  _tool(.cup, 1, 2),
  _tool(.cup, 1, 3),
  _tool(.cup, 1, 4),
  _tool(.cup, 1, 8),
]);

/// The measuring spoons settings offers, largest first.
final List<MeasuringTool> measuringSpoons = List.unmodifiable([
  _tool(.tablespoon, 1),
  _tool(.tablespoon, 1, 2),
  _tool(.teaspoon, 1),
  _tool(.teaspoon, 1, 2),
  _tool(.teaspoon, 1, 4),
  _tool(.teaspoon, 1, 8),
]);

/// The set assumed until the user changes theirs (PRD 7.5): every offered
/// tool except the ⅛ cup and ⅛ tsp (BUILD_PLAN.md §8.10).
final List<MeasuringTool> defaultMeasuringTools = List.unmodifiable([
  for (final tool in [...measuringCups, ...measuringSpoons])
    if (tool.capacity != Quantity(1, 8)) tool,
]);

/// The measuring cups and spoons the user owns: the ones they saved, or
/// [defaultMeasuringTools] until they change any.
@riverpod
Stream<List<MeasuringTool>> ownedMeasuringTools(Ref ref) => ref
    .watch(measuringToolRepositoryProvider)
    .watchTools()
    .map((saved) => saved.isEmpty ? defaultMeasuringTools : saved);

/// Changes which measuring tools the user owns.
@riverpod
class MeasuringToolsController() extends _$MeasuringToolsController {
  @override
  void build() {}

  /// Marks [tool] as owned or not. The first change saves the default set
  /// first, so the other tools stay as they were.
  Future<void> setOwned(MeasuringTool tool, {required bool owned}) async {
    final repository = ref.read(measuringToolRepositoryProvider);
    final saved = await repository.watchTools().first;
    if (saved.isEmpty) {
      for (final defaultTool in defaultMeasuringTools) {
        await repository.saveTool(defaultTool);
      }
    }
    await (owned ? repository.saveTool(tool) : repository.deleteTool(tool.id));
  }
}
