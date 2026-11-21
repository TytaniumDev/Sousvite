import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/services/feedback_service.dart';
import 'package:sousvite/features/feedback/application/feedback_draft.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The report's message and reply email. The fields start from the draft
/// and then keep their own text, so typing never rebuilds them.
class const FeedbackFields({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<FeedbackFields> createState() => _FeedbackFieldsState();
}

class _FeedbackFieldsState() extends ConsumerState<FeedbackFields> {
  late final _message = TextEditingController(
    text: ref.read(feedbackDraftProvider).message,
  );
  late final _email = TextEditingController(
    text: ref.read(feedbackDraftProvider).email,
  );

  @override
  void dispose() {
    _message.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A sent report starts a new, empty draft.
    ref.listen(feedbackDraftProvider, (_, next) {
      if (next == const FeedbackReport()) {
        _message.clear();
        _email.clear();
      }
    });
    final l10n = context.l10n;
    final draft = ref.read(feedbackDraftProvider.notifier);
    return Column(
      crossAxisAlignment: .stretch,
      spacing: AppSpacing.space4,
      children: [
        TextField(
          controller: _message,
          onChanged: draft.updateMessage,
          minLines: 4,
          maxLines: null,
          textCapitalization: .sentences,
          decoration: InputDecoration(
            labelText: l10n.feedback_messageLabel,
            hintText: l10n.feedback_messageHint,
            alignLabelWithHint: true,
          ),
        ),
        TextField(
          controller: _email,
          onChanged: draft.updateEmail,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            labelText: l10n.feedback_emailLabel,
            helperText: l10n.feedback_emailHelper,
          ),
        ),
      ],
    );
  }
}
