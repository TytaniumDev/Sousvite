import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/recipe/application/recipe_data.dart';
import 'package:sousvite/features/recipe/presentation/section_title.dart';
import 'package:sousvite/l10n/l10n.dart';

/// The recipe's notes. Hidden when there are none.
class const RecipeNotes({
  /// The recipe whose notes this shows.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(
      recipeProvider(recipeId).select((recipe) => recipe.value?.notes ?? ''),
    );
    if (notes.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space8),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          SectionTitle(context.l10n.recipe_notes),
          const SizedBox(height: AppSpacing.space3),
          Text(notes, style: context.textStyles.bodyLarge),
        ],
      ),
    );
  }
}
