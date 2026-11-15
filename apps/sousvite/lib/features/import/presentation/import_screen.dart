import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/import/presentation/umami_section.dart';
import 'package:sousvite/features/import/presentation/url_import_form.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Brings recipes in from a web page or an Umami library, and sends them
/// back out to Umami (PRD 7.2).
class const ImportScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.import_title)),
      body: ListView(
        children: [
          SectionHeader(title: l10n.import_fromWeb),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            child: UrlImportForm(),
          ),
          const SizedBox(height: AppSpacing.space6),
          SectionHeader(title: l10n.import_umami),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            child: UmamiSection(),
          ),
        ],
      ),
    );
  }
}
