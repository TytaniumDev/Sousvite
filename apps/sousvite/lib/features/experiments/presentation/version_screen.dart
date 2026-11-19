import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/experiments/application/experiment_actions.dart';
import 'package:sousvite/features/experiments/application/history_providers.dart';
import 'package:sousvite/l10n/l10n.dart';
import 'package:sousvite/shared/units/unit_words.dart';
import 'package:sousvite/shared/widgets/async_value_view.dart';

/// A past version, read-only, with a button that restores it (PRD 7.11).
class const VersionScreen({
  /// The recipe the version belongs to.
  required final RecipeId recipeId,

  /// The version shown.
  required final RecipeVersionId versionId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final createdAt = ref.watch(
      historyVersionProvider(
        recipeId,
        versionId,
      ).select((v) => v.value?.createdAt),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          createdAt == null
              ? l10n.experiments_savedVersion
              : MaterialLocalizations.of(context).formatMediumDate(createdAt),
        ),
      ),
      // A snapshot never changes, so the whole page reads it once.
      body: AsyncValueView(
        value: ref.watch(versionSnapshotProvider(versionId)),
        data: (snapshot) => snapshot == null
            ? Center(child: Text(l10n.experiments_versionNotFound))
            : _Snapshot(snapshot: snapshot, versionId: versionId),
      ),
    );
  }
}

class const _Snapshot({
  required final RecipeSnapshot snapshot,
  required final RecipeVersionId versionId,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textStyles = context.textStyles;
    return ReadingColumn(
      builder: (context, insets) => FadingEdges(
        child: ListView(
          padding:
              insets + const EdgeInsets.symmetric(vertical: AppSpacing.space4),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
              ),
              child: Text(
                snapshot.recipe.title,
                style: textStyles.headlineLarge,
              ),
            ),
            SectionHeader(title: l10n.experiments_ingredients),
            CompactDensity(
              child: Column(
                children: [
                  for (final line in snapshot.ingredientLines)
                    IngredientRow(
                      key: ValueKey(line.id),
                      name: line.name ?? line.rawText,
                      quantity: line.quantity,
                      unit: line.quantity == null
                          ? null
                          : l10n.unitWord(
                              line.unit,
                              line.quantity!,
                              countWord: line.countWord,
                            ),
                      preparation: line.preparation,
                    ),
                ],
              ),
            ),
            SectionHeader(title: l10n.experiments_steps),
            for (final (index, step) in snapshot.steps.indexed)
              ListTile(
                key: ValueKey(step.id),
                leading: Text('${index + 1}', style: textStyles.titleMedium),
                title: Text(step.text),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: _RestoreButton(versionId: versionId),
            ),
          ],
        ),
      ),
    );
  }
}

class const _RestoreButton({required final RecipeVersionId versionId})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => FilledButton(
    onPressed: () async {
      final messenger = ScaffoldMessenger.of(context);
      final router = GoRouter.of(context);
      final restored = context.l10n.experiments_restored;
      await ref.read(experimentActionsProvider).restore(versionId);
      messenger.showSnackBar(SnackBar(content: Text(restored)));
      if (router.canPop()) router.pop();
    },
    child: Text(context.l10n.experiments_restore),
  );
}
