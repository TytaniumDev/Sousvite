import 'package:material_ui/material_ui.dart';

/// Builds a controlled component with local state, so a use case responds
/// to taps even though design_system widgets hold no state of their own.
///
/// [initialValue] usually comes from a knob. When the knob changes, the
/// local value follows it.
class const Interactive<T>({
  /// The value to start from.
  required final T initialValue,

  /// Builds the component from the current value and a callback that
  /// changes it.
  required final Widget Function(
    BuildContext context,
    T value,
    ValueChanged<T> onChanged,
  )
  builder,
  super.key,
}) extends StatefulWidget {
  @override
  State<Interactive<T>> createState() => _InteractiveState<T>();
}

class _InteractiveState<T>() extends State<Interactive<T>> {
  late T _value = widget.initialValue;

  @override
  void didUpdateWidget(Interactive<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _value = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    _value,
    (value) => setState(() => _value = value),
  );
}
