import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/account/account_routes.dart';
import 'package:sousvite/features/account/sync/application/sign_in_callout.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The library's dismissible card telling signed-out users that signing in
/// with Google gives free backup and sync through their Drive
/// (ENGINEERING.md §10). "Not now" hides it for 30 days.
class const SignInCalloutCard({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(signInCalloutVisibleProvider)) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    return Card.filled(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                const Icon(Symbols.cloud_upload_rounded),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Text(
                    l10n.account_signInCalloutTitle,
                    style: context.textStyles.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(l10n.account_signInCalloutBody),
            const SizedBox(height: AppSpacing.space2),
            Row(
              mainAxisAlignment: .end,
              children: [
                TextButton(
                  onPressed: () => unawaited(
                    ref.read(signInCalloutDismissalProvider.notifier).dismiss(),
                  ),
                  child: Text(l10n.account_signInCalloutDismiss),
                ),
                const SizedBox(width: AppSpacing.space2),
                FilledButton.tonal(
                  onPressed: () => unawaited(context.push(AccountRoutes.path)),
                  child: Text(l10n.account_signInCalloutAction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The Settings row with the same invitation, shown whenever the user is
/// signed out (ENGINEERING.md §10).
class const SignInCalloutTile({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(signInInviteAvailableProvider)) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    return ListTile(
      leading: const Icon(Symbols.cloud_upload_rounded),
      title: Text(l10n.account_signInCalloutTitle),
      subtitle: Text(l10n.account_signInCalloutBody),
      onTap: () => unawaited(context.push(AccountRoutes.path)),
    );
  }
}
