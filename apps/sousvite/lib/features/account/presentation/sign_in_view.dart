import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/account/application/account_controller.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Why to sign in, and the Google and Apple buttons. Both buttons look the
/// same, as App Store guideline 4.8 asks.
class const SignInView({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final busy = ref.watch(
      accountControllerProvider.select((state) => state.isLoading),
    );
    final controller = ref.read(accountControllerProvider.notifier);
    return ReadingColumn(
      maxWidth: ReadingColumn.formWidth,
      builder: (context, insets) => ListView(
        padding: insets + const EdgeInsets.all(AppSpacing.space4),
        children: [
          Text(l10n.account_signInBody, style: context.textStyles.bodyLarge),
          const SizedBox(height: AppSpacing.space6),
          FilledButton.tonal(
            onPressed: busy ? null : controller.signInWithGoogle,
            child: Text(l10n.account_signInWithGoogle),
          ),
          const SizedBox(height: AppSpacing.space3),
          FilledButton.tonal(
            onPressed: busy ? null : controller.signInWithApple,
            child: Text(l10n.account_signInWithApple),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            l10n.account_driveNeedsGoogle,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
