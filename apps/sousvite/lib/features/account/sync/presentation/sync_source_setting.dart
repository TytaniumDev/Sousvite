import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/services/auth_service.dart';
import 'package:sousvite/features/account/application/auth_user.dart';
import 'package:sousvite/features/account/sync/application/sync_controller.dart';
import 'package:sousvite/features/account/sync/application/sync_source.dart';
import 'package:sousvite/features/account/sync/application/sync_source_controller.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The Sync source setting (Beta), for signed-in users: Sousvite cloud or
/// Google Drive (ENGINEERING.md §10). Switching copies the library into the
/// new source first, so nothing is lost.
class const SyncSourceSetting({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final method = ref.watch(
      authUserProvider.select((user) => user.value?.method),
    );
    final signedIn = ref.watch(
      authUserProvider.select((user) => user.value != null),
    );
    if (!signedIn) return const SizedBox.shrink();
    final l10n = context.l10n;
    final source = ref.watch(syncSourceControllerProvider).value ?? .cloud;
    final canUseDrive = method == SignInMethod.google;
    return ListTile(
      leading: const Icon(Symbols.cloud_sync_rounded),
      title: Row(
        children: [
          Flexible(child: Text(l10n.account_syncSource)),
          const SizedBox(width: AppSpacing.space2),
          const _BetaLabel(),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: .start,
        children: [
          const SizedBox(height: AppSpacing.space2),
          SegmentedButton<SyncSource>(
            segments: [
              ButtonSegment(
                value: .cloud,
                label: Text(l10n.account_syncSourceCloud),
              ),
              ButtonSegment(
                value: .drive,
                label: Text(l10n.account_syncSourceDrive),
                enabled: canUseDrive,
              ),
            ],
            selected: {source},
            onSelectionChanged: (selected) =>
                unawaited(_switch(context, ref, selected.single)),
          ),
          if (!canUseDrive) ...[
            const SizedBox(height: AppSpacing.space1),
            Text(l10n.account_syncSourceDriveNeedsGoogle),
          ],
          const _LastSynced(),
        ],
      ),
    );
  }

  Future<void> _switch(
    BuildContext context,
    WidgetRef ref,
    SyncSource source,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.account_syncSourceSwitchFailed;
    try {
      await ref.read(syncControllerProvider.notifier).switchTo(source);
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }
}

class const _BetaLabel() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.tertiaryContainer,
      borderRadius: AppRadii.borderSm,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
      child: Text(
        context.l10n.account_syncSourceBeta,
        style: context.textStyles.labelSmall?.copyWith(
          color: context.colors.onTertiaryContainer,
        ),
      ),
    ),
  );
}

/// When the last sync finished. Watches only that time.
class const _LastSynced() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final at = ref.watch(
      syncControllerProvider.select((state) => state.lastSyncedAt),
    );
    if (at == null) return const SizedBox.shrink();
    final time = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(at));
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space2),
      child: Text(context.l10n.account_lastSynced(time)),
    );
  }
}
