import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';

/// A text field that keeps its own controller (so the cursor never jumps) and
/// re-syncs when [value] changes from the outside, e.g. an AI fill.
class OutcomesMapSyncedField extends StatefulWidget {
  final String value;
  final String hint;
  final String? label;
  final int? maxLength;
  final int maxLines;
  final ValueChanged<String> onChanged;

  const OutcomesMapSyncedField({
    super.key,
    required this.value,
    required this.hint,
    required this.onChanged,
    this.label,
    this.maxLength,
    this.maxLines = 1,
  });

  @override
  State<OutcomesMapSyncedField> createState() => _OutcomesMapSyncedFieldState();
}

class _OutcomesMapSyncedFieldState extends State<OutcomesMapSyncedField> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant OutcomesMapSyncedField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryTextField(
      controller: _controller,
      label: widget.label,
      hint: widget.hint,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
    );
  }
}
