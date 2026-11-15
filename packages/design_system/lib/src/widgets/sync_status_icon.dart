import 'package:design_system/src/theme/context_ext.dart';
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
class const SyncStatusIcon({
  /// The state to show.
  required final SyncIconStatus status,

  /// The words for [status], already localized: "Synced", "Offline". The
  /// tooltip shows them and a screen reader reads them.
  required final String label,
  super.key,
}) extends StatelessWidget {
  /// The size of the area that opens the tooltip, a full tap target.
  static const double size = kMinInteractiveDimension;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (icon, color) = switch (status) {
      .synced => (Symbols.cloud_done_rounded, colors.onSurfaceVariant),
      .syncing => (Symbols.sync_rounded, colors.onSurfaceVariant),
      .offline => (Symbols.cloud_off_rounded, colors.onSurfaceVariant),
      .error => (Symbols.sync_problem_rounded, colors.error),
    };
    final glyph = Icon(icon, color: color);
    return Tooltip(
      message: label,
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: status == .syncing ? _Turning(child: glyph) : glyph,
        ),
      ),
    );
  }
}

/// Turns its child once every [period], or holds still under reduced
/// motion. Kept in its own widget so the ticking stays local.
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
      RotationTransition(turns: _controller, child: widget.child);
}
