import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// A recipe in a list or grid: photo, name in the serif, total time,
/// calories per serving, and optional badges (DESIGN_SYSTEM.md §9.2).
///
/// The parent sets the width; the photo keeps a 4:3 shape and the name
/// wraps onto two lines at most. A screen reader reads the card as one
/// button.
class const RecipeCard({
  /// The recipe name.
  required final String title,

  /// The photo, or null to show a placeholder. A photo that fails to load
  /// shows the placeholder too.
  final ImageProvider? image,

  /// The total time, already formatted: "45 min". Null when unknown.
  final String? totalTimeLabel,

  /// Calories per serving, already formatted: "520 kcal". Null when the
  /// recipe has no nutrition yet.
  final String? caloriesLabel,

  /// Badges under the name, such as `ShareBadge` and `ExperimentBadge`.
  final List<Widget> badges = const [],

  /// Called when the card is tapped. Null for a card that does nothing.
  final VoidCallback? onTap,
  super.key,
}) extends StatelessWidget {
  /// The photo's width to height.
  static const double photoAspectRatio = 4 / 3;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: .antiAlias,
    child: MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: .stretch,
          mainAxisSize: .min,
          children: [
            AspectRatio(
              aspectRatio: photoAspectRatio,
              child: _Photo(image: image),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space3),
              child: _Details(
                title: title,
                totalTimeLabel: totalTimeLabel,
                caloriesLabel: caloriesLabel,
                badges: badges,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class const _Photo({required final ImageProvider? image})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final image = this.image;
    if (image == null) return const _PhotoPlaceholder();
    return Image(
      image: image,
      fit: .cover,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => const _PhotoPlaceholder(),
    );
  }
}

class const _PhotoPlaceholder() extends StatelessWidget {
  static const double _iconSize = 40;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.surfaceContainerHighest,
    child: Center(
      child: Icon(
        Symbols.restaurant_rounded,
        size: _iconSize,
        color: context.colors.onSurfaceVariant,
      ),
    ),
  );
}

class const _Details({
  required final String title,
  required final String? totalTimeLabel,
  required final String? caloriesLabel,
  required final List<Widget> badges,
}) extends StatelessWidget {
  static const int _titleMaxLines = 2;

  @override
  Widget build(BuildContext context) {
    final totalTimeLabel = this.totalTimeLabel;
    final caloriesLabel = this.caloriesLabel;
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        Text(
          title,
          style: context.textStyles.titleLarge,
          maxLines: _titleMaxLines,
          overflow: .ellipsis,
        ),
        if (totalTimeLabel != null || caloriesLabel != null) ...[
          const SizedBox(height: AppSpacing.space1),
          Wrap(
            spacing: AppSpacing.space3,
            runSpacing: AppSpacing.space1,
            children: [
              if (totalTimeLabel != null)
                _Fact(icon: Symbols.schedule_rounded, label: totalTimeLabel),
              if (caloriesLabel != null)
                _Fact(
                  icon: Symbols.local_fire_department_rounded,
                  label: caloriesLabel,
                ),
            ],
          ),
        ],
        if (badges.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space2),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: badges,
          ),
        ],
      ],
    );
  }
}

/// A small icon and a short fact: the time or the calories.
class const _Fact({required final IconData icon, required final String label})
    extends StatelessWidget {
  static const double _iconSize = 16;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.onSurfaceVariant;
    return Row(
      mainAxisSize: .min,
      children: [
        Icon(icon, size: _iconSize, color: color),
        const SizedBox(width: AppSpacing.space1),
        Flexible(
          child: Text(
            label,
            style: context.textStyles.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
