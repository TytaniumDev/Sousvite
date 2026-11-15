import 'package:design_system/design_system.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Where the nutrition data comes from, and the open source licenses.
///
/// Open Food Facts data is under the Open Database License, which asks for
/// this attribution wherever the data is used.
class const AboutSection({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
          child: Text(
            l10n.settings_dataAttribution,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Symbols.license_rounded),
          title: Text(l10n.settings_licenses),
          trailing: const Icon(Symbols.chevron_right_rounded),
          onTap: () => showLicensePage(
            context: context,
            applicationName: l10n.app_title,
            applicationLegalese: l10n.settings_dataAttribution,
          ),
        ),
      ],
    );
  }
}
