import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/import/presentation/umami_section.dart';
import 'package:sousvite/features/import/presentation/url_import_form.dart';
import 'package:sousvite/features/library/library.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Brings recipes in from a web page or an Umami library, and sends them
/// back out to Umami (PRD 7.2).
///
/// A link shared from another app arrives as [sharedText], and an Umami
/// export as [sharedArchive]. Either starts importing right away.
class const ImportScreen({
  /// Text shared from another app, holding the recipe's link.
  final String? sharedText,

  /// Where the platform left an Umami export shared from another app.
  final String? sharedArchive,

  /// The folder a recipe imported from a link goes into. Null leaves it
  /// unsorted, as for a link shared from another app.
  final FolderId? folderId,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PageScaffold(
      title: Text(l10n.import_title),
      // Opened from the share sheet, there is nothing to go back to.
      leading: context.canPop()
          ? null
          : IconButton(
              tooltip: l10n.import_close,
              icon: const Icon(Symbols.close_rounded),
              onPressed: () => context.go(LibraryRoutes.path),
            ),
      body: ReadingColumn(
        builder: (context, insets) => FadingEdges(
          child: ListView(
            padding: insets,
            children: [
              SectionHeader(title: l10n.import_fromWeb),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                ),
                child: UrlImportForm(
                  sharedText: sharedText,
                  folderId: folderId,
                ),
              ),
              const SizedBox(height: AppSpacing.space6),
              SectionHeader(title: l10n.import_umami),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                ),
                child: UmamiSection(sharedArchive: sharedArchive),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
