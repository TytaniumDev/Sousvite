import 'package:domain/domain.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Unicode fractions for the sizes measuring tools come in.
const _fractions = {
  '1/8': '⅛',
  '1/4': '¼',
  '1/3': '⅓',
  '1/2': '½',
  '2/3': '⅔',
  '3/4': '¾',
};

/// A tool's name as cooks say it, such as "¾ cup" or "½ Tbsp".
///
/// Settings offers only cups and spoons, so this handles only those. Other
/// amounts are formatted by `packages/measuring` once it exists.
String measuringToolLabel(AppLocalizations l10n, MeasuringTool tool) {
  final amount = _fractions['${tool.capacity}'] ?? '${tool.capacity}';
  return switch (tool.unit) {
    .cup => l10n.settings_toolCup(amount),
    .tablespoon => l10n.settings_toolTablespoon(amount),
    _ => l10n.settings_toolTeaspoon(amount),
  };
}
