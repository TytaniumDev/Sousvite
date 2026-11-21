import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/feedback/application/feedback_draft.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Sends the report once it has a message, then closes the form. Rebuilds
/// only when the message starts or stops being empty.
class const SendFeedbackButton({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<SendFeedbackButton> createState() => _SendFeedbackButtonState();
}

class _SendFeedbackButtonState() extends ConsumerState<SendFeedbackButton> {
  bool _sending = false;

  Future<void> _send() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _sending = true);
    try {
      await ref.read(feedbackDraftProvider.notifier).send();
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(l10n.feedback_failed)));
      return;
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    messenger.showSnackBar(SnackBar(content: Text(l10n.feedback_sent)));
    if (mounted && context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasMessage = ref.watch(
      feedbackDraftProvider.select((d) => d.message.trim().isNotEmpty),
    );
    return FilledButton(
      onPressed: hasMessage && !_sending ? _send : null,
      child: Text(context.l10n.feedback_send),
    );
  }
}
