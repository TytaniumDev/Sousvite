import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/library/application/library_filter.dart';
import 'package:sousvite/l10n/l10n.dart';

/// Searches recipes by title, ingredient, and folder (PRD 7.1).
///
/// It only writes the query, so typing never rebuilds this field through
/// Riverpod; the text field keeps its own text.
class const LibrarySearchField({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
    child: SearchBar(
      hintText: context.l10n.library_searchHint,
      leading: const Icon(Symbols.search_rounded),
      onChanged: (query) =>
          ref.read(libraryQueryProvider.notifier).update(query),
    ),
  );
}
