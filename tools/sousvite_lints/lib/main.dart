import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:sousvite_lints/src/fade_scroll_views.dart';

/// The plugin the analysis server loads from `analysis_options.yaml`.
final plugin = SousviteLintsPlugin();

/// Registers Sousvite's own lint rules.
class SousviteLintsPlugin() extends Plugin {
  @override
  String get name => 'sousvite_lints';

  @override
  void register(PluginRegistry registry) {
    registry.registerWarningRule(FadeScrollViews());
  }
}
