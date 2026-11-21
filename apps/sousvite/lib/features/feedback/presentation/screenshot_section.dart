import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/feedback/application/feedback_capture.dart';
import 'package:sousvite/features/feedback/application/feedback_draft.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The report's screenshot: a button that steps away to capture one, or
/// the captured screen with a button to remove it. Rebuilds only when the
/// screenshot changes.
class const ScreenshotSection({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final png = ref.watch(feedbackDraftProvider.select((d) => d.screenshot));
    return png == null ? const _AddScreenshot() : _Screenshot(png: png);
  }
}

class const _AddScreenshot() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: .stretch,
      spacing: AppSpacing.space2,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Symbols.screenshot_region_rounded),
          label: Text(l10n.feedback_addScreenshot),
          onPressed: () {
            // The capture bar shows over the app while the form is closed.
            ref.read(feedbackCaptureProvider.notifier).start();
            if (context.canPop()) context.pop();
          },
        ),
        Text(
          l10n.feedback_addScreenshotHelp,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class const _Screenshot({required final Uint8List png}) extends ConsumerWidget {
  /// Tall enough to read a phone screen, short enough to leave the Send
  /// button in view.
  static const double _height = 240;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      spacing: AppSpacing.space2,
      children: [
        ClipRRect(
          borderRadius: AppRadii.borderLg,
          child: Image.memory(
            png,
            height: _height,
            fit: .contain,
            semanticLabel: l10n.feedback_screenshotLabel,
          ),
        ),
        TextButton.icon(
          icon: const Icon(Symbols.delete_rounded),
          label: Text(l10n.feedback_removeScreenshot),
          onPressed: ref.read(feedbackDraftProvider.notifier).removeScreenshot,
        ),
      ],
    );
  }
}
