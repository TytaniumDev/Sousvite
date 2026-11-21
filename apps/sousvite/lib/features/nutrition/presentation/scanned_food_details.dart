import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/services/nutrition_api.dart';
import 'package:sousvite/features/nutrition/application/nutrient.dart';
import 'package:sousvite/features/nutrition/application/nutrition_math.dart';
import 'package:sousvite/features/nutrition/presentation/nutrition_words.dart';
import 'package:sousvite/l10n/l10n.dart';

/// What an ingredient line scanned from a barcode was matched to, under
/// the line, so the user can check it (PRD 7.3): the package's photo, its
/// name and brand, where its nutrition comes from, and the calories and
/// macros in the amount the line gives, which follow the line as it
/// changes.
class const ScannedFoodDetails({
  /// The product the line was scanned from.
  required final ScannedProduct product,

  /// The line, for the amount its nutrition is worked out for.
  required final IngredientLine line,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final (:food, :imageUrl) = product;
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: .start,
        spacing: AppSpacing.space3,
        children: [
          _ProductPhoto(url: imageUrl, name: food.food.name),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              spacing: AppSpacing.space1,
              children: [
                Text(food.food.name, style: context.textStyles.titleSmall),
                _Source(food: food.food),
                _LineNutrition(food: food, line: line),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A small photo of the package's front, or a grocery icon when there is
/// none or it doesn't load.
class const _ProductPhoto({required final Uri? url, required final String name})
    extends StatelessWidget {
  /// The width and height of the photo.
  static const double size = AppSpacing.space16;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    return ClipRRect(
      borderRadius: AppRadii.borderMd,
      child: ColoredBox(
        color: context.colors.surfaceContainerLowest,
        child: SizedBox.square(
          dimension: size,
          child: url == null
              ? const _PhotoPlaceholder()
              : Image.network(
                  url.toString(),
                  fit: .contain,
                  semanticLabel: context.l10n.nutrition_productPhoto(name),
                  // Shows the photo even where the site blocks reading it.
                  webHtmlElementStrategy: .fallback,
                  errorBuilder: (_, _, _) => const _PhotoPlaceholder(),
                ),
        ),
      ),
    );
  }
}

/// Stands in for a product photo that's missing.
class const _PhotoPlaceholder() extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Icon(Symbols.grocery_rounded, color: context.colors.onSurfaceVariant);
}

/// The product's brand, if known, and where its nutrition comes from.
class const _Source({required final Food food}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final status = matchStatusOfSource(food.source);
    final brand = food.brand;
    return Wrap(
      crossAxisAlignment: .center,
      spacing: AppSpacing.space2,
      runSpacing: AppSpacing.space1,
      children: [
        if (brand != null)
          Text(
            brand,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        MatchStatusChip(
          status: status,
          label: context.l10n.matchStatus(status),
        ),
      ],
    );
  }
}

/// Calories and macros in the amount [line] gives, or what to type when
/// it can't be weighed yet.
class const _LineNutrition({
  required final OnlineFood food,
  required final IngredientLine line,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final grams = estimateGrams(line, food.portions, foodName: food.food.name);
    final text = switch (grams) {
      null => l10n.nutrition_scannedNeedsAmount,
      final grams => _nutrition(l10n, nutrientsIn(grams, food.nutrients)),
    };
    return Text(
      text,
      style: context.textStyles.bodySmall?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
    );
  }

  static String _nutrition(AppLocalizations l10n, NutrientAmounts amounts) {
    String grams(Nutrient nutrient) =>
        NutrientPrecision.grams.format(amounts[nutrient] ?? 0);
    return l10n.nutrition_scannedNutrition(
      NutrientPrecision.whole.format(amounts[Nutrient.calories] ?? 0),
      grams(.protein),
      grams(.carbs),
      grams(.fat),
    );
  }
}
