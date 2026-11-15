import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/settings/application/measuring_tools.dart';
import 'package:sousvite/features/settings/presentation/measuring_tool_label.dart';
import 'package:sousvite/features/settings/presentation/section_title.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Which measuring cups and spoons the user owns (PRD 7.5). Cooking mode
/// suggests only these.
class const MeasuringToolsScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings_measuringTools)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            child: Text(
              l10n.settings_measuringToolsDescription,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          SectionTitle(l10n.settings_measuringCups),
          for (final tool in measuringCups)
            MeasuringToolTile(key: ValueKey(tool.id), tool: tool),
          SectionTitle(l10n.settings_measuringSpoons),
          for (final tool in measuringSpoons)
            MeasuringToolTile(key: ValueKey(tool.id), tool: tool),
        ],
      ),
    );
  }
}

/// One cup or spoon with a switch for whether the user owns it. Rebuilds
/// only when that changes, or when it becomes or stops being the last one,
/// which can't be turned off.
class const MeasuringToolTile({
  /// The cup or spoon this row shows.
  required final MeasuringTool tool,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (:owned, :isLast) = ref.watch(
      ownedMeasuringToolsProvider.select((tools) {
        final owned = tools.value?.any((t) => t.id == tool.id) ?? false;
        return (owned: owned, isLast: owned && tools.value?.length == 1);
      }),
    );
    final l10n = context.l10n;
    return SwitchListTile(
      title: Text(measuringToolLabel(l10n, tool)),
      subtitle: isLast ? Text(l10n.settings_measuringToolsKeepOne) : null,
      value: owned,
      onChanged: isLast
          ? null
          : (owned) => ref
                .read(measuringToolsControllerProvider.notifier)
                .setOwned(tool, owned: owned),
    );
  }
}
