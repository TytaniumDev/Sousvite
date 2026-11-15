import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/services/auth_service.dart';
import 'package:sousvite/features/account/application/account_controller.dart';
import 'package:sousvite/features/account/application/auth_user.dart';
import 'package:sousvite/features/account/presentation/delete_account_button.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The signed-in account, sign out, and delete account.
class const SignedInView({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
    children: const [
      _AccountSummary(),
      _SignOutButton(),
      SizedBox(height: AppSpacing.space8),
      DeleteAccountButton(),
    ],
  );
}

/// Who is signed in, and with what. Rebuilds only when those change.
class const _AccountSummary() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final (:name, :email, :method) = ref.watch(
      authUserProvider.select((state) {
        final user = state.value;
        return (
          name: user?.displayName,
          email: user?.email,
          method: user?.method,
        );
      }),
    );
    return ListTile(
      leading: const Icon(Symbols.account_circle_rounded),
      title: Text(name ?? email ?? l10n.account_unnamedUser),
      subtitle: Text(
        [
          if (name != null) ?email,
          switch (method) {
            SignInMethod.google => l10n.account_signedInWithGoogle,
            SignInMethod.apple => l10n.account_signedInWithApple,
            null => l10n.account_signedIn,
          },
        ].join('\n'),
      ),
    );
  }
}

class const _SignOutButton() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(
      accountControllerProvider.select((state) => state.isLoading),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(
            context.l10n.account_signOutNote,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          OutlinedButton(
            onPressed: busy
                ? null
                : ref.read(accountControllerProvider.notifier).signOut,
            child: Text(context.l10n.account_signOut),
          ),
        ],
      ),
    );
  }
}
