import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:material_ui/material_ui.dart';

/// An icon, a title, one sentence, and an optional action, centered: the
/// layout `EmptyState` and `ErrorState` share (DESIGN_SYSTEM.md §10.8).
class const StateMessage({
  /// The icon above the title.
  required final IconData icon,

  /// The icon color.
  required final Color iconColor,

  /// The heading, already localized.
  required final String title,

  /// One sentence under the title, already localized.
  required final String message,

  /// The one thing to do next, usually a button. Null for none.
  final Widget? action,
  super.key,
}) extends StatelessWidget {
  /// The widest the text gets, so lines stay readable on tablets.
  static const double maxWidth = 360;

  /// The icon size.
  static const double iconSize = 48;

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    final textStyles = context.textStyles;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Column(
            mainAxisSize: .min,
            children: [
              Icon(icon, size: iconSize, color: iconColor),
              const SizedBox(height: AppSpacing.space4),
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: textStyles.titleLarge,
                  textAlign: .center,
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                message,
                style: textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: .center,
              ),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.space6),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
