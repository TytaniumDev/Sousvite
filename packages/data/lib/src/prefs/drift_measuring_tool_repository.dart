import 'package:collection/collection.dart';
import 'package:data/src/app_database.dart';
import 'package:data/src/change_log/change_recorder.dart';
import 'package:data/src/change_log/entity_applier.dart';
import 'package:data/src/change_log/materializing_applier.dart';
import 'package:data/src/daos/measuring_tool_dao.dart';
import 'package:data/src/prefs/prefs_codecs.dart';
import 'package:domain/domain.dart';

/// [MeasuringToolRepository] over the local database. The tools sync
/// across the user's own devices.
final class DriftMeasuringToolRepository(
  /// The database the tools and the change log live in.
  final AppDatabase database, {

  /// Records each write's changes for sync.
  required final ChangeRecorder recorder,
}) implements MeasuringToolRepository {
  MeasuringToolDao get _dao => database.measuringToolDao;

  static final _codec = MeasuringToolCodec();

  /// Writes remote changes for tools, for `DriftLocalStore`.
  Map<String, EntityApplier> get appliers => {
    _codec.entity: MaterializingApplier(
      database,
      codec: _codec,
      write: (tool) => _dao.upsert(_toCompanion(tool)),
      remove: _dao.deleteTool,
    ),
  };

  /// Every tool, grouped by unit with the largest first.
  @override
  Stream<List<MeasuringTool>> watchTools() => _dao
      .allTools()
      .watch()
      .map((rows) => [for (final row in rows) _toEntity(row)])
      .distinct(const ListEquality<MeasuringTool>().equals);

  @override
  Future<void> saveTool(MeasuringTool tool) => recorder.write((changes) async {
    final before = await _dao.tool(tool.id.value).getSingleOrNull();
    changes.setChanged(
      _codec,
      tool,
      before: before == null ? null : _toEntity(before),
    );
    await _dao.upsert(_toCompanion(tool));
  });

  @override
  Future<void> deleteTool(MeasuringToolId id) =>
      recorder.write((changes) async {
        await _dao.deleteTool(id.value);
        changes.delete(_codec.entity, id.value);
      });

  static MeasuringTool _toEntity(MeasuringToolRow row) => MeasuringTool(
    id: MeasuringToolId(row.id),
    capacity: Quantity(row.capacityNumerator, row.capacityDenominator),
    unit: row.unit,
  );

  static MeasuringToolsCompanion _toCompanion(MeasuringTool tool) =>
      MeasuringToolsCompanion.insert(
        id: tool.id.value,
        capacityNumerator: tool.capacity.numerator,
        capacityDenominator: tool.capacity.denominator,
        unit: tool.unit,
      );
}
