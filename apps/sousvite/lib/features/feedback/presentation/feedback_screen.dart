import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/feedback/presentation/feedback_fields.dart';
import 'package:sousvite/features/feedback/presentation/screenshot_section.dart';
import 'package:sousvite/features/feedback/presentation/send_feedback_button.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The form for a bug report or a suggestion, with an optional screenshot
/// of the screen it is about.
class const FeedbackScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PageScaffold(
      // The feedback form needs no button that opens itself.
      showPageActions: false,
      title: Text(l10n.feedback_title),
      body: ReadingColumn(
        maxWidth: ReadingColumn.formWidth,
        builder: (context, insets) => FadingEdges(
          child: ListView(
            padding: insets + const EdgeInsets.all(AppSpacing.space4),
            children: [
              Text(l10n.feedback_intro, style: context.textStyles.bodyLarge),
              const SizedBox(height: AppSpacing.space6),
              const FeedbackFields(),
              const SizedBox(height: AppSpacing.space6),
              const ScreenshotSection(),
              const SizedBox(height: AppSpacing.space6),
              const SendFeedbackButton(),
            ],
          ),
        ),
      ),
    );
  }
}
