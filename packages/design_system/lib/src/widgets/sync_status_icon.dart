import 'package:design_system/src/theme/context_ext.dart';
import 'package:design_system/src/widgets/padded_ink_well.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// What the sync status icon shows.
enum SyncIconStatus() {
  /// Everything is saved to the cloud.
  synced,

  /// Changes are being sent or received.
  syncing,

  /// No connection; changes wait on the device.
  offline,

  /// Sync failed and needs attention.
  error,
}

/// Sync state as a small icon with a tooltip, for the library header and
/// settings (DESIGN_SYSTEM.md §9.2, §10.9).
///
/// Offline is not an error: it is shown in the same quiet color as synced.
/// Only [SyncIconStatus.error] uses the error color. While syncing, the
/// icon turns, unless the platform asks for reduced motion (§8.3).
///
/// With [onTap] it is a round button, such as one that asks the user to
/// sign in again; its ink keeps the icon centered with even padding.
class const SyncStatusIcon({
  /// The state to show.
  required final SyncIconStatus status,

  /// The words for [status], already localized: "Synced", "Offline". The
  /// tooltip shows them and a screen reader reads them.
  required final String label,

  /// Called when the icon is tapped. Null for an icon that only shows the
  /// state.
  final VoidCallback? onTap,
  super.key,
}) extends StatelessWidget {
  /// The size of the area that opens the tooltip, a full tap target.
  static const double size = kMinInteractiveDimension;

  static const double _glyphSize = 24;

  /// The space around the glyph inside [size].
  static const double _inset = (size - _glyphSize) / 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (icon, color) = switch (status) {
      .synced => (Symbols.cloud_done_rounded, colors.onSurfaceVariant),
      .syncing => (Symbols.sync_rounded, colors.onSurfaceVariant),
      .offline => (Symbols.cloud_off_rounded, colors.onSurfaceVariant),
      .error => (Symbols.sync_problem_rounded, colors.error),
    };
    final glyph = Icon(icon, color: color, size: _glyphSize);
    final shown = status == .syncing ? _Turning(child: glyph) : glyph;
    final onTap = this.onTap;
    return Tooltip(
      message: label,
      child: onTap == null
          ? SizedBox.square(
              dimension: size,
              child: Center(child: shown),
            )
          : Semantics(
              button: true,
              child: PaddedInkWell(
                onTap: onTap,
                horizontal: _inset,
                vertical: _inset,
                customBorder: const CircleBorder(),
                child: shown,
              ),
            ),
    );
  }
}

/// Turns its child counterclockwise once every [period], the way the
/// arrows of the sync symbol point, or holds still under reduced motion.
/// Kept in its own widget so the ticking stays local.
class const _Turning({required final Widget child}) extends StatefulWidget {
  static const period = Duration(milliseconds: 1500);

  @override
  State<_Turning> createState() => _TurningState();
}

class _TurningState()
    extends State<_Turning>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: _Turning.period,
  );

  // Negative turns go counterclockwise, matching the symbol's arrows.
  late final Animation<double> _turns = Tween<double>(
    begin: 0,
    end: -1,
  ).animate(_controller);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      // The returned future never completes for a repeating controller.
      _controller.repeat().ignore();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RotationTransition(turns: _turns, child: widget.child);
}
