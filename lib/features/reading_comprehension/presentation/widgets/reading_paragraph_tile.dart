import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reading_comprehension/data/models/reading_models.dart';

/// One numbered paragraph with reorder/delete controls and a character counter.
class ReadingParagraphTile extends StatefulWidget {
  final int index;
  final int total;
  final String text;
  final String? error;
  final ValueChanged<String> onChanged;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onDelete;

  const ReadingParagraphTile({
    super.key,
    required this.index,
    required this.total,
    required this.text,
    required this.onChanged,
    this.error,
    this.onMoveUp,
    this.onMoveDown,
    this.onDelete,
  });

  @override
  State<ReadingParagraphTile> createState() => _ReadingParagraphTileState();
}

class _ReadingParagraphTileState extends State<ReadingParagraphTile> {
  late final TextEditingController _controller = TextEditingController(text: widget.text);

  @override
  void didUpdateWidget(covariant ReadingParagraphTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != _controller.text) _controller.text = widget.text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.error != null ? ColorsManager.errorColor : ColorsManager.borderLightGray,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  '${widget.index + 1}',
                  style: TextStylesManager.bold13.copyWith(color: ColorsManager.primaryColor),
                ),
              ),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: widget.onMoveUp,
                icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 20),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: widget.onMoveDown,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: widget.onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: widget.onDelete == null ? ColorsManager.borderColor : ColorsManager.errorColor,
                ),
              ),
            ],
          ),
          TextField(
            controller: _controller,
            maxLines: null,
            minLines: 3,
            maxLength: ReadingLimits.maxParagraphLength,
            textDirection: _directionOf(_controller.text),
            style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText, height: 1.6),
            decoration: InputDecoration(
              hintText: appTranslation().get('reading_paragraph_hint'),
              hintStyle: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: widget.onChanged,
          ),
          if (widget.error != null) ...[
            verticalSpace4,
            Text(
              appTranslation().get(widget.error!),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.errorColor),
            ),
          ],
        ],
      ),
    );
  }

  static TextDirection _directionOf(String text) =>
      RegExp(r'[؀-ۿ]').hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
}
