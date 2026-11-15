import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/tokens/radii.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// A horizontal bar of protein, carbs, and fat by their share of calories,
/// with small gaps between segments (DESIGN_SYSTEM.md §9.2).
///
/// It is always labeled nearby, by `MacroSummary` or a legend, so it is
/// hidden from screen readers. The gaps keep the segments apart without
/// relying on hue alone.
class const MacroBar({
  /// Protein in grams.
  required final double protein,

  /// Carbohydrates in grams.
  required final double carbs,

  /// Fat in grams.
  required final double fat,
  super.key,
}) extends StatelessWidget {
  /// The bar's height.
  static const double height = 8;

  /// The gap between segments.
  static const double gap = 2;

  /// Calories per gram of protein, carbs, and fat (Atwater factors).
  static const ({double protein, double carbs, double fat}) caloriesPerGram = (
    protein: 4,
    carbs: 4,
    fat: 9,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _MacroBarPainter(
            segments: [
              (protein * caloriesPerGram.protein, colors.protein),
              (carbs * caloriesPerGram.carbs, colors.carbs),
              (fat * caloriesPerGram.fat, colors.fat),
            ],
            track: context.colors.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}

class _MacroBarPainter({
  required final List<(double, Color)> segments,
  required final Color track,
}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppRadii.xs),
    );
    canvas.clipRRect(shape);
    final visible = [
      for (final (calories, color) in segments)
        if (calories > 0) (calories, color),
    ];
    final total = visible.fold<double>(0, (sum, s) => sum + s.$1);
    if (total <= 0) {
      canvas.drawRRect(shape, Paint()..color = track);
      return;
    }
    final gaps = MacroBar.gap * (visible.length - 1);
    final width = size.width - gaps;
    var x = 0.0;
    for (final (calories, color) in visible) {
      final segment = width * calories / total;
      canvas.drawRect(
        Rect.fromLTWH(x, 0, segment, size.height),
        Paint()..color = color,
      );
      x += segment + MacroBar.gap;
    }
  }

  @override
  bool shouldRepaint(_MacroBarPainter oldDelegate) =>
      track != oldDelegate.track || !listEquals(segments, oldDelegate.segments);
}
