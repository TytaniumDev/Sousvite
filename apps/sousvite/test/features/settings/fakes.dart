import 'dart:async';

import 'package:domain/domain.dart';

/// Keeps settings in memory and emits each save, like the Drift
/// repository will.
class FakeAppSettingsRepository([AppSettings initial = const AppSettings()])
    implements AppSettingsRepository {
  var _current = initial;
  final _saves = StreamController<AppSettings>.broadcast();

  /// The last saved settings.
  AppSettings get current => _current;

  @override
  Stream<AppSettings> watchSettings() async* {
    yield _current;
    yield* _saves.stream;
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _current = settings;
    _saves.add(settings);
  }
}

/// Keeps measuring tools in memory, in the order they were saved.
class FakeMeasuringToolRepository([List<MeasuringTool> initial = const []])
    implements MeasuringToolRepository {
  final Map<MeasuringToolId, MeasuringTool> _tools = {
    for (final tool in initial) tool.id: tool,
  };
  final _changes = StreamController<List<MeasuringTool>>.broadcast();

  /// The saved tools.
  List<MeasuringTool> get tools => List.unmodifiable(_tools.values);

  @override
  Stream<List<MeasuringTool>> watchTools() async* {
    yield tools;
    yield* _changes.stream;
  }

  @override
  Future<void> saveTool(MeasuringTool tool) async {
    _tools[tool.id] = tool;
    _changes.add(tools);
  }

  @override
  Future<void> deleteTool(MeasuringToolId id) async {
    _tools.remove(id);
    _changes.add(tools);
  }
}
