import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// One way to share: a heading, what it does, and its controls below.
class const ShareOptionCard({
  required final IconData icon,
  required final String title,
  required final String body,
  required final Widget child,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card.filled(
    color: context.colors.surfaceContainerLow,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.colors.primary),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: context.textStyles.titleMedium),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            body,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          child,
        ],
      ),
    ),
  );
}
