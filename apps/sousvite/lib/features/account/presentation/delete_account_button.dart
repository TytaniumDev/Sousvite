import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/account/application/account_controller.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Deletes the account after the user confirms (PRD 7.9). A dialog, because
/// this can't be undone (DESIGN_SYSTEM.md §10.8).
class const DeleteAccountButton({super.key}) extends ConsumerWidget {
  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final deletedMessage = context.l10n.account_deleted;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _ConfirmDeleteDialog(),
    );
    if (confirmed != true) return;
    final outcome = await ref
        .read(accountControllerProvider.notifier)
        .deleteAccount();
    if (outcome == .completed) {
      messenger.showSnackBar(SnackBar(content: Text(deletedMessage)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(
      accountControllerProvider.select((state) => state.isLoading),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: TextButton(
        style: TextButton.styleFrom(foregroundColor: context.colors.error),
        onPressed: busy ? null : () => _confirmAndDelete(context, ref),
        child: Text(context.l10n.account_deleteAccount),
      ),
    );
  }
}

class const _ConfirmDeleteDialog() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.account_deleteTitle),
      content: Text(l10n.account_deleteBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: context.colors.error),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.account_deleteConfirm),
        ),
      ],
    );
  }
}
