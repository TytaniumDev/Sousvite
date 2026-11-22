import 'package:analysis_server_plugin/registry.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:sousvite_lints/main.dart';
import 'package:sousvite_lints/src/fade_scroll_views.dart';
import 'package:sousvite_lints/src/padded_ink_wells.dart';
import 'package:sousvite_lints/src/page_scaffolds.dart';
import 'package:test/test.dart';

void main() {
  group(SousviteLintsPlugin, () {
    test('is named for its package', () {
      expect(plugin.name, 'sousvite_lints');
    });

    test('registers every rule as a warning', () {
      final registry = _RecordingRegistry();
      plugin.register(registry);
      expect(registry.warningRules, [
        isA<FadeScrollViews>(),
        isA<PaddedInkWells>(),
        isA<PageScaffolds>(),
      ]);
    });
  });
}

/// Records the rules a plugin registers.
class _RecordingRegistry() implements PluginRegistry {
  final warningRules = <AbstractAnalysisRule>[];

  @override
  void registerWarningRule(AbstractAnalysisRule rule) => warningRules.add(rule);

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
