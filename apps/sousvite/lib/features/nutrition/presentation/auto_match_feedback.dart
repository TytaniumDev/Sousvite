import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/nutrition/application/auto_match.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Runs [match] with the app's [AutoMatch], then says in a snack bar how
/// many ingredients were matched and how many still need the user.
Future<void> runAutoMatch(
  BuildContext context,
  WidgetRef ref,
  Future<AutoMatchResult> Function(AutoMatch autoMatch) match,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final (:matched, :unmatched) = await match(
    await ref.read(autoMatchProvider.future),
  );
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        [
          l10n.nutrition_matchedCount(matched),
          if (unmatched > 0) l10n.nutrition_stillUnmatched(unmatched),
        ].join(' '),
      ),
    ),
  );
}
