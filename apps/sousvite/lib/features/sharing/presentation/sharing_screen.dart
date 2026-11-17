import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/account/account.dart';
import 'package:sousvite/features/sharing/application/share_links.dart';
import 'package:sousvite/features/sharing/presentation/copy_link_option.dart';
import 'package:sousvite/features/sharing/presentation/joint_share_option.dart';
import 'package:sousvite/features/sharing/presentation/sign_in_prompt.dart';
import 'package:sousvite/features/sharing/presentation/view_only_link_option.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// Share a recipe: edit it together, send a copy, or publish a link for
/// anyone (PRD 7.10).
/// Sharing needs sign-in, so signed-out users are asked to sign in first.
class const SharingScreen({required final RecipeId recipeId, super.key})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void showFailure(Object? _, AsyncValue<Object?> next) {
      if (next case AsyncError()) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.sharing_failed)));
      }
    }

    ref
      ..listen(jointLinkProvider(recipeId), showFailure)
      ..listen(copyLinkProvider(recipeId), showFailure)
      ..listen(viewOnlyLinkProvider(recipeId), showFailure);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.sharing_title)),
      body: AsyncValueView(
        value: ref.watch(
          authUserProvider.select((user) => user.whenData((u) => u != null)),
        ),
        data: (signedIn) => signedIn
            ? _Options(recipeId: recipeId)
            : SignInPrompt(message: context.l10n.sharing_signInBody),
      ),
    );
  }
}

class const _Options({required final RecipeId recipeId})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.space4),
    children: [
      JointShareOption(recipeId: recipeId),
      const SizedBox(height: AppSpacing.space4),
      CopyLinkOption(recipeId: recipeId),
      const SizedBox(height: AppSpacing.space4),
      ViewOnlyLinkOption(recipeId: recipeId),
    ],
  );
}
