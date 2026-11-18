import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/import/application/umami_progress.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Shows how far the running Umami import has got, and closes itself when
/// the import ends. It can't be dismissed: the import runs either way.
class const UmamiImportDialog({super.key}) extends ConsumerStatefulWidget {
  /// Opens the dialog over [context].
  static Future<void> show(BuildContext context) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const UmamiImportDialog(),
  );

  @override
  ConsumerState<UmamiImportDialog> createState() => _UmamiImportDialogState();
}

class _UmamiImportDialogState() extends ConsumerState<UmamiImportDialog> {
  bool _closing = false;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(umamiProgressProvider);
    if (progress == null && !_closing) {
      _closing = true;
      // The route can't pop while it builds.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
    final l10n = context.l10n;
    final status = switch (progress) {
      UmamiImportProgress(stage: .recipes, :final done, :final total) =>
        l10n.import_umamiSavingRecipes(done, total),
      UmamiImportProgress(stage: .photos, :final done, :final total) =>
        l10n.import_umamiSavingPhotos(done, total),
      _ => l10n.import_umamiReading,
    };
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(l10n.import_umamiImportingTitle),
        content: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          spacing: AppSpacing.space3,
          children: [
            Text(status, style: context.textStyles.bodyMedium),
            LinearProgressIndicator(value: progress?.fraction),
            Text(
              l10n.import_umamiKeepOpen,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
