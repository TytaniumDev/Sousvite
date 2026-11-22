import 'dart:async';

import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/feedback/presentation/feedback_capture_layer.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The app bar button on every page that opens the feedback form with a
/// screenshot of that page attached.
class const FeedbackButton({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.l10n.feedback_tile,
    icon: const Icon(Symbols.feedback_rounded),
    onPressed: () => unawaited(FeedbackCaptureLayer.captureAndOpen(context)),
  );
}
