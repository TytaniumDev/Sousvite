import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/import/application/import_failure.dart';
import 'package:sousvite/features/import/application/umami_actions.dart';
import 'package:sousvite/features/import/presentation/import_failure_text.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Import an Umami library, or export recipes for Umami (PRD 7.2). The
/// outcome shows in a snackbar.
///
/// An export shared from another app arrives as [sharedArchive] and starts
/// importing right away.
class const UmamiSection({
  /// Where the platform left an Umami export shared from another app.
  final String? sharedArchive,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<UmamiSection> createState() => _UmamiSectionState();
}

class _UmamiSectionState() extends ConsumerState<UmamiSection> {
  @override
  void initState() {
    super.initState();
    final archive = widget.sharedArchive;
    if (archive == null) return;
    // Providers can't change while the tree builds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        _run(
          context,
          () => ref
              .read(umamiActionsProvider.notifier)
              .importSharedArchive(archive),
          context.l10n.import_umamiImported,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final task = ref.watch(umamiActionsProvider);
    final l10n = context.l10n;
    final actions = ref.read(umamiActionsProvider.notifier);
    return Column(
      crossAxisAlignment: .stretch,
      spacing: AppSpacing.space3,
      children: [
        Text(l10n.import_umamiMessage, style: context.textStyles.bodyMedium),
        OutlinedButton.icon(
          onPressed: task == null
              ? () => _run(
                  context,
                  actions.importLibrary,
                  l10n.import_umamiImported,
                )
              : null,
          icon: const Icon(Symbols.download_rounded),
          label: Text(
            task == .importing
                ? l10n.import_umamiImporting
                : l10n.import_umamiImport,
          ),
        ),
        OutlinedButton.icon(
          onPressed: task == null
              ? () => _run(
                  context,
                  actions.exportLibrary,
                  l10n.import_umamiExported,
                )
              : null,
          icon: const Icon(Symbols.upload_rounded),
          label: Text(
            task == .exporting
                ? l10n.import_umamiExporting
                : l10n.import_umamiExport,
          ),
        ),
      ],
    );
  }

  Future<void> _run(
    BuildContext context,
    Future<int?> Function() transfer,
    String Function(int count) done,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    String? message;
    try {
      final count = await transfer();
      if (count != null) message = done(count);
    } on ImportFailure catch (failure) {
      message = l10n.importFailure(failure);
    }
    if (message != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
