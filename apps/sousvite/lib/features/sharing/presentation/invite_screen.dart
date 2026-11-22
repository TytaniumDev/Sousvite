import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/account/account.dart';
import 'package:sousvite/features/sharing/presentation/invite_offer.dart';
import 'package:sousvite/features/sharing/presentation/sign_in_prompt.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// Opens an invite link: says what it offers and lets the user accept it
/// (PRD 7.10). Signed-out users are asked to sign in first.
class const InviteScreen({
  /// The invite's id, from the link.
  required final String inviteId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => PageScaffold(
    title: Text(context.l10n.sharing_inviteTitle),
    body: AsyncValueView(
      value: ref.watch(
        authUserProvider.select((user) => user.whenData((u) => u != null)),
      ),
      data: (signedIn) => signedIn
          ? InviteOffer(inviteId: inviteId)
          : SignInPrompt(message: context.l10n.sharing_inviteSignIn),
    ),
  );
}

/// An invite that expired, was never made, or whose share ended.
class const InviteGone({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Symbols.link_off_rounded,
    title: context.l10n.sharing_inviteGone,
    message: context.l10n.sharing_inviteGoneBody,
  );
}
