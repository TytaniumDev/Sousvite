import 'package:material_ui/material_ui.dart';

/// A text field that starts from the draft and then keeps its own text,
/// so typing never rebuilds it from state (and never moves the cursor).
class const DraftTextField({
  /// The text when the field first appears.
  required final String initialText,

  /// Called with the text on every change.
  required final ValueChanged<String> onChanged,

  /// The field's label, or null for none.
  final String? label,

  /// Shown while the field is empty.
  final String? hint,

  /// The text style, or null for the theme's.
  final TextStyle? style,

  /// The keyboard to show.
  final TextInputType? keyboardType,

  /// Null lets the field grow with its text.
  final int? maxLines = 1,

  /// Whether the field takes focus when it appears, for a line just added.
  final bool autofocus = false,
  super.key,
}) extends StatefulWidget {
  @override
  State<DraftTextField> createState() => _DraftTextFieldState();
}

class _DraftTextFieldState() extends State<DraftTextField> {
  late final _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    onChanged: widget.onChanged,
    style: widget.style,
    keyboardType: widget.keyboardType,
    maxLines: widget.maxLines,
    minLines: 1,
    autofocus: widget.autofocus,
    textCapitalization: .sentences,
    decoration: InputDecoration(labelText: widget.label, hintText: widget.hint),
  );
}
