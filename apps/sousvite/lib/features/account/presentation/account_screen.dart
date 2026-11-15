import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/account/application/account_controller.dart';
import 'package:sousvite/features/account/application/auth_user.dart';
import 'package:sousvite/features/account/presentation/sign_in_view.dart';
import 'package:sousvite/features/account/presentation/signed_in_view.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// Sign in, or see and manage the signed-in account (PRD 7.9). Rebuilds
/// only when the user signs in or out.
class const AccountScreen({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(accountControllerProvider, (_, next) {
      if (next case AsyncError()) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.account_error)));
      }
    });
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.account_title)),
      body: AsyncValueView(
        value: ref.watch(
          authUserProvider.select((user) => user.whenData((u) => u != null)),
        ),
        data: (signedIn) =>
            signedIn ? const SignedInView() : const SignInView(),
      ),
    );
  }
}
