import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/account/account.dart';
import 'package:sousvite/features/settings/presentation/about_section.dart';
import 'package:sousvite/features/settings/presentation/section_title.dart';
import 'package:sousvite/features/settings/presentation/theme_setting.dart';
import 'package:sousvite/features/settings/presentation/unit_system_setting.dart';
import 'package:sousvite/features/settings/settings_routes.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The Settings tab: appearance, recipes, account, and about.
class const SettingsScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings_title)),
      body: ListView(
        children: [
          SectionTitle(l10n.settings_appearance),
          const ThemeSetting(),
          SectionTitle(l10n.settings_recipes),
          const UnitSystemSetting(),
          const _MeasuringToolsTile(),
          SectionTitle(l10n.settings_account),
          const SignInCalloutTile(),
          const _AccountTile(),
          const SyncSourceSetting(),
          SectionTitle(l10n.settings_about),
          const AboutSection(),
        ],
      ),
    );
  }
}

class const _MeasuringToolsTile() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Symbols.straighten_rounded),
    title: Text(context.l10n.settings_measuringTools),
    trailing: const Icon(Symbols.chevron_right_rounded),
    onTap: () => context.go(SettingsRoutes.measuringToolsPath),
  );
}

class const _AccountTile() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Symbols.account_circle_rounded),
    title: Text(context.l10n.settings_accountTile),
    trailing: const Icon(Symbols.chevron_right_rounded),
    onTap: () => context.push(AccountRoutes.path),
  );
}
