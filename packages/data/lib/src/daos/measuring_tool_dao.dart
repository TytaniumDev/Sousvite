import 'package:data/src/app_database.dart';
import 'package:data/src/tables/measuring_tool_tables.dart';
import 'package:drift/drift.dart';

part 'measuring_tool_dao.g.dart';

/// Queries for the measuring tools the user owns.
@DriftAccessor(tables: [MeasuringTools])
class MeasuringToolDao(super.attachedDatabase)
    extends DatabaseAccessor<AppDatabase>
    with _$MeasuringToolDaoMixin {
  /// Every tool by unit, then largest first.
  Selectable<MeasuringToolRow> allTools() => select(measuringTools)
    ..orderBy([
      (row) => OrderingTerm.asc(row.unit),
      (row) => OrderingTerm.desc(
        row.capacityNumerator.cast<double>() /
            row.capacityDenominator.cast<double>(),
      ),
      (row) => OrderingTerm.asc(row.id),
    ]);

  /// The tool with [id].
  Selectable<MeasuringToolRow> tool(String id) =>
      select(measuringTools)..where((row) => row.id.equals(id));

  /// Inserts or replaces a tool row.
  Future<void> upsert(MeasuringToolsCompanion row) =>
      into(measuringTools).insertOnConflictUpdate(row);

  /// Deletes the tool row with [id].
  Future<void> deleteTool(String id) =>
      (delete(measuringTools)..where((row) => row.id.equals(id))).go();
}
