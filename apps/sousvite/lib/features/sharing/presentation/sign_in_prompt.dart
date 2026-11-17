import 'package:design_system/design_system.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/account/account.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Asks a signed-out user to sign in, since sharing goes through Sousvite.
class const SignInPrompt({
  /// Why signing in helps here.
  required final String message,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Symbols.account_circle_rounded,
    title: context.l10n.sharing_signInTitle,
    message: message,
    action: FilledButton(
      onPressed: () => context.push(AccountRoutes.path),
      child: Text(context.l10n.sharing_signIn),
    ),
  );
}
