import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/features/recipe/application/recipe_data.dart';
import 'package:sousvite/shared/photos/photos.dart';

/// The recipe's photo at the top of the page: full width on phones, with
/// rounded corners on wider screens (DESIGN_SYSTEM.md §10.1). Nothing when
/// the recipe has no photo, or it can't be loaded.
class const RecipePhoto({
  /// The recipe whose photo this shows.
  required final RecipeId recipeId,
  super.key,
}) extends ConsumerWidget {
  /// The photo's width to height.
  static const double aspectRatio = 16 / 10;

  /// The tallest the photo gets on wide screens, so the recipe still
  /// starts above the fold.
  static const double maxHeight = 420;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoRef = ref.watch(
      recipeProvider(recipeId).select((recipe) => recipe.value?.photoRef),
    );
    if (photoRef == null) return const SizedBox.shrink();
    final compact = WindowSizeClass.of(context) == .compact;
    final image = Image(
      image: ref.watch(recipePhotosProvider).imageFor(photoRef),
      fit: .cover,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
    if (compact) {
      return AspectRatio(aspectRatio: aspectRatio, child: image);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: maxHeight),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: ClipRRect(borderRadius: AppRadii.borderLg, child: image),
        ),
      ),
    );
  }
}
