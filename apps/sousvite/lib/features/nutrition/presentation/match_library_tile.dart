import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/nutrition/presentation/auto_match_feedback.dart';
import 'package:sousvite/l10n/l10n.dart';

/// A settings row that matches the unmatched ingredients of every recipe
/// in the library, where a USDA food clearly fits.
class const MatchLibraryTile({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<MatchLibraryTile> createState() => _MatchLibraryTileState();
}

class _MatchLibraryTileState() extends ConsumerState<MatchLibraryTile> {
  var _running = false;

  Future<void> _matchLibrary() async {
    setState(() => _running = true);
    try {
      await runAutoMatch(context, ref, (autoMatch) => autoMatch.matchLibrary());
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: const Icon(Symbols.nutrition_rounded),
      title: Text(l10n.nutrition_matchLibrary),
      subtitle: Text(l10n.nutrition_matchLibraryDescription),
      enabled: !_running,
      onTap: _matchLibrary,
    );
  }
}
