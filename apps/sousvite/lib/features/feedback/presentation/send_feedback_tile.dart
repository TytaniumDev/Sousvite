import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/feedback/application/feedback_capture.dart';
import 'package:sousvite/features/feedback/feedback_routes.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The Settings row that opens the feedback form.
class const SendFeedbackTile({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ListTile(
      leading: const Icon(Symbols.feedback_rounded),
      title: Text(l10n.feedback_tile),
      subtitle: Text(l10n.feedback_tileDescription),
      trailing: const Icon(Symbols.chevron_right_rounded),
      onTap: () {
        // Opening the form ends a capture the user walked away from.
        ref.read(feedbackCaptureProvider.notifier).stop();
        unawaited(context.push(FeedbackRoutes.path));
      },
    );
  }
}
