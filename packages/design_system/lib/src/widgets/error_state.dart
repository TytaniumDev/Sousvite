import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/widgets/state_message.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// What went wrong and what to do next, with a retry button
/// (DESIGN_SYSTEM.md §9.2, §10.8). No apology, no error codes (§11).
class const ErrorState({
  /// What went wrong, already localized: "Couldn't load this recipe".
  required final String title,

  /// What to do about it, already localized: "Check your connection and
  /// try again."
  required final String message,

  /// The retry button's words, already localized: "Try again".
  required final String retryLabel,

  /// Called when the retry button is pressed.
  required final VoidCallback onRetry,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StateMessage(
    icon: Symbols.error_rounded,
    iconColor: context.colors.error,
    title: title,
    message: message,
    action: FilledButton.tonal(onPressed: onRetry, child: Text(retryLabel)),
  );
}
