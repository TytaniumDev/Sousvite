import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/settings/application/theme_mode_controller.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Light, dark, or follow the system. Rebuilds only when the theme mode
/// changes.
class const ThemeSetting({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: SegmentedButton<ThemeMode>(
        segments: [
          ButtonSegment(value: .system, label: Text(l10n.settings_themeSystem)),
          ButtonSegment(value: .light, label: Text(l10n.settings_themeLight)),
          ButtonSegment(value: .dark, label: Text(l10n.settings_themeDark)),
        ],
        selected: {ref.watch(themeModeControllerProvider)},
        onSelectionChanged: (selection) => ref
            .read(themeModeControllerProvider.notifier)
            .select(selection.single),
      ),
    );
  }
}
