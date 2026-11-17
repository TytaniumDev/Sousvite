import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/account/sync/application/sync_controller.dart';
import 'package:sousvite/features/account/sync/application/sync_state.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The sync status in the library header (ENGINEERING.md §8.2, DESIGN_SYSTEM
/// §10.9). Hidden while sync is off. When Google needs the user again for
/// Drive, it becomes a button that asks.
class const SyncStatusButton({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(
      syncControllerProvider.select((state) => state.phase),
    );
    final l10n = context.l10n;
    final (status, label) = switch (phase) {
      .off => (null, ''),
      .syncing => (SyncIconStatus.syncing, l10n.account_syncSyncing),
      .synced => (SyncIconStatus.synced, l10n.account_syncSynced),
      .offline => (SyncIconStatus.offline, l10n.account_syncOffline),
      .error => (SyncIconStatus.error, l10n.account_syncError),
      .signInAgain => (SyncIconStatus.error, l10n.account_syncSignInAgain),
    };
    if (status == null) return const SizedBox.shrink();
    final icon = SyncStatusIcon(status: status, label: label);
    if (phase != SyncPhase.signInAgain) return icon;
    return Semantics(
      button: true,
      child: InkResponse(
        onTap: () =>
            unawaited(ref.read(syncControllerProvider.notifier).signInAgain()),
        child: icon,
      ),
    );
  }
}
