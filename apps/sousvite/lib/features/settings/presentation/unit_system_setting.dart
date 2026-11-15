import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/settings/application/unit_system_controller.dart';
import 'package:sousvite/l10n/l10n.dart';

/// As written, US, or metric amounts. Rebuilds only when the choice
/// changes.
class const UnitSystemSetting({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(l10n.settings_units, style: context.textStyles.bodyLarge),
          Text(
            l10n.settings_unitsDescription,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          SegmentedButton<UnitSystem>(
            segments: [
              ButtonSegment(
                value: .original,
                label: Text(l10n.settings_unitsOriginal),
              ),
              ButtonSegment(value: .us, label: Text(l10n.settings_unitsUs)),
              ButtonSegment(
                value: .metric,
                label: Text(l10n.settings_unitsMetric),
              ),
            ],
            selected: {ref.watch(unitSystemControllerProvider)},
            onSelectionChanged: (selection) => ref
                .read(unitSystemControllerProvider.notifier)
                .select(selection.single),
          ),
        ],
      ),
    );
  }
}
