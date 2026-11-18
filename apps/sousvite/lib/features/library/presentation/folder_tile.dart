import 'package:design_system/design_system.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// A folder in the library's grid: a square collage of up to four recipe
/// photos, the folder name, and how many recipes it holds.
///
/// Takes plain values, so it can move into design_system once a second
/// feature shows folders. The parent sets the width. A screen reader reads
/// the tile as one button.
class const FolderTile({
  /// The folder name.
  required final String title,

  /// What the collage shows, newest first. Only the first four are used.
  /// Empty shows [placeholderIcon] instead.
  required final List<ImageProvider> images,

  /// Called when the tile is tapped.
  required final VoidCallback onTap,

  /// How many recipes the folder holds, already worded: "12 recipes".
  /// Null hides it.
  final String? countLabel,

  /// Shown when there are no [images].
  final IconData placeholderIcon = Symbols.folder_rounded,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final countLabel = this.countLabel;
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.borderLg,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: Column(
              crossAxisAlignment: .stretch,
              mainAxisSize: .min,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: AppRadii.borderLg,
                    child: images.isEmpty
                        ? _Placeholder(icon: placeholderIcon)
                        : _Collage(images: images),
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  title,
                  style: context.textStyles.titleSmall,
                  maxLines: 2,
                  overflow: .ellipsis,
                ),
                if (countLabel != null)
                  Text(
                    countLabel,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One photo fills the square; two sit side by side; three put the newest
/// on the left and two stacked on the right; four make a 2 by 2 grid.
class const _Collage({required final List<ImageProvider> images})
    extends StatelessWidget {
  /// The hairline between photos.
  static const double _gap = 2;

  @override
  Widget build(BuildContext context) {
    final photos = [for (final image in images.take(4)) _Photo(image: image)];
    return switch (photos) {
      [final only] => only,
      [final left, final right] => _Split(
        axis: .horizontal,
        children: [left, right],
      ),
      [final left, final top, final bottom] => _Split(
        axis: .horizontal,
        children: [
          left,
          _Split(axis: .vertical, children: [top, bottom]),
        ],
      ),
      _ => _Split(
        axis: .vertical,
        children: [
          _Split(axis: .horizontal, children: [photos[0], photos[1]]),
          _Split(axis: .horizontal, children: [photos[2], photos[3]]),
        ],
      ),
    };
  }
}

/// Two parts of the collage, sharing the space equally.
class const _Split({
  required final Axis axis,
  required final List<Widget> children,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Flex(
    direction: axis,
    crossAxisAlignment: .stretch,
    spacing: _Collage._gap,
    children: [for (final child in children) Expanded(child: child)],
  );
}

class const _Photo({required final ImageProvider image})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Image(
    image: image,
    fit: .cover,
    excludeFromSemantics: true,
    errorBuilder: (_, _, _) =>
        const _Placeholder(icon: Symbols.restaurant_rounded),
  );
}

class const _Placeholder({required final IconData icon})
    extends StatelessWidget {
  static const double _iconSize = 32;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.surfaceContainerHighest,
    child: Center(
      child: Icon(
        icon,
        size: _iconSize,
        color: context.colors.onSurfaceVariant,
      ),
    ),
  );
}
