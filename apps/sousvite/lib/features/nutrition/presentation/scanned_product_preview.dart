import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/services/nutrition_api.dart';
import 'package:sousvite/features/nutrition/application/nutrient.dart';
import 'package:sousvite/features/nutrition/application/nutrition_math.dart';
import 'package:sousvite/features/nutrition/application/scanned_food.dart';
import 'package:sousvite/features/nutrition/presentation/nutrition_words.dart';
import 'package:sousvite/l10n/l10n.dart';

/// What a scanned barcode found, so the user can check it before adding
/// it: the package's photo, its name and brand, where its nutrition comes
/// from, calories and macros in one label serving, and the ingredient line
/// adding it creates (PRD 7.3).
class const ScannedProductPreview({
  /// The product the barcode found.
  required final ScannedProduct product,

  /// Adds the product to the recipe.
  required final VoidCallback onAdd,

  /// Goes back to the camera.
  required final VoidCallback onScanAgain,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final (:food, :imageUrl) = product;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Expanded(
          child: ReadingColumn(
            maxWidth: ReadingColumn.formWidth,
            builder: (context, insets) => FadingEdges(
              child: ListView(
                padding:
                    insets + const EdgeInsets.all(ReadingColumn.contentPadding),
                children: [
                  _ProductPhoto(url: imageUrl, name: food.food.name),
                  const SizedBox(height: AppSpacing.space4),
                  _ProductName(food: food.food),
                  const SizedBox(height: AppSpacing.space6),
                  _ServingNutrition(food: food),
                  const SizedBox(height: AppSpacing.space6),
                  _AddedLine(food: food),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: ReadingColumn(
            maxWidth: ReadingColumn.formWidth,
            builder: (context, insets) => Padding(
              padding:
                  insets + const EdgeInsets.all(ReadingColumn.contentPadding),
              child: _Actions(onAdd: onAdd, onScanAgain: onScanAgain),
            ),
          ),
        ),
      ],
    );
  }
}

/// The photo of the package's front, or a grocery icon when there is none
/// or it doesn't load.
class const _ProductPhoto({required final Uri? url, required final String name})
    extends StatelessWidget {
  /// The width and height of the photo's frame.
  static const double size = 160;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    return Center(
      child: ClipRRect(
        borderRadius: AppRadii.borderLg,
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
      ),
    );
  }
}

/// Stands in for a product photo that's missing.
class const _PhotoPlaceholder() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Icon(
    Symbols.grocery_rounded,
    size: AppSpacing.space12,
    color: context.colors.onSurfaceVariant,
  );
}

/// The product's name, then its brand and where its nutrition comes from.
class const _ProductName({required final Food food}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = matchStatusOfSource(food.source);
    final brand = food.brand;
    return Column(
      spacing: AppSpacing.space2,
      children: [
        Text(
          food.name,
          textAlign: .center,
          style: context.textStyles.titleLarge,
        ),
        Wrap(
          alignment: .center,
          crossAxisAlignment: .center,
          spacing: AppSpacing.space2,
          runSpacing: AppSpacing.space2,
          children: [
            if (brand != null)
              Text(
                brand,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            MatchStatusChip(status: status, label: l10n.matchStatus(status)),
          ],
        ),
      ],
    );
  }
}

/// Calories and macros in one label serving, or in 100 g when the label
/// gives no serving in grams.
class const _ServingNutrition({required final OnlineFood food})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final servingGrams = labelServingGrams(food);
    final amounts = nutrientsIn(servingGrams ?? 100, food.nutrients);
    return MacroSummary(
      calories: amounts[Nutrient.calories] ?? 0,
      protein: amounts[Nutrient.protein] ?? 0,
      carbs: amounts[Nutrient.carbs] ?? 0,
      fat: amounts[Nutrient.fat] ?? 0,
      basisLabel: switch (servingGrams) {
        final grams? => l10n.nutrition_perServingGrams(formatGrams(grams)),
        null => l10n.nutrition_per100Grams,
      },
      labels: l10n.macroLabels,
    );
  }
}

/// The ingredient line adding the product creates.
class const _AddedLine({required final OnlineFood food})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final line = scannedLineText(food);
    return Text(
      labelServingGrams(food) == null
          ? l10n.nutrition_scanAddsLineNoServing(line)
          : l10n.nutrition_scanAddsLine(line),
      style: context.textStyles.bodyMedium?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
    );
  }
}

/// "Scan again" and "Add to recipe".
class const _Actions({
  required final VoidCallback onAdd,
  required final VoidCallback onScanAgain,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => OverflowBar(
    alignment: .end,
    overflowAlignment: .end,
    spacing: AppSpacing.space2,
    overflowSpacing: AppSpacing.space2,
    children: [
      TextButton(
        onPressed: onScanAgain,
        child: Text(context.l10n.nutrition_scanAgain),
      ),
      FilledButton(
        onPressed: onAdd,
        child: Text(context.l10n.nutrition_addProduct),
      ),
    ],
  );
}
