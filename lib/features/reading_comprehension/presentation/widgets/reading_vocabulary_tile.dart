import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reading_comprehension/data/models/reading_models.dart';

/// One vocabulary row: «الكلمة» and «معناها», with a delete button.
class ReadingVocabularyTile extends StatefulWidget {
  final int index;
  final String word;
  final String meaning;
  final String? error;
  final ValueChanged<String> onWordChanged;
  final ValueChanged<String> onMeaningChanged;
  final VoidCallback onDelete;

  const ReadingVocabularyTile({
    super.key,
    required this.index,
    required this.word,
    required this.meaning,
    required this.onWordChanged,
    required this.onMeaningChanged,
    required this.onDelete,
    this.error,
  });

  @override
  State<ReadingVocabularyTile> createState() => _ReadingVocabularyTileState();
}

class _ReadingVocabularyTileState extends State<ReadingVocabularyTile> {
  late final TextEditingController _word = TextEditingController(text: widget.word);
  late final TextEditingController _meaning = TextEditingController(text: widget.meaning);

  @override
  void didUpdateWidget(covariant ReadingVocabularyTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.word != _word.text) _word.text = widget.word;
    if (widget.meaning != _meaning.text) _meaning.text = widget.meaning;
  }

  @override
  void dispose() {
    _word.dispose();
    _meaning.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hintKey) => InputDecoration(
        hintText: appTranslation().get(hintKey),
        hintStyle: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
        isDense: true,
        filled: true,
        fillColor: ColorsManager.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorsManager.borderLightGray)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorsManager.borderLightGray)),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _word,
                  maxLength: ReadingLimits.maxWordLength,
                  style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                  decoration: _decoration('reading_vocab_word'),
                  onChanged: widget.onWordChanged,
                ),
              ),
              horizontalSpace8,
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _meaning,
                  maxLength: ReadingLimits.maxMeaningLength,
                  style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
                  decoration: _decoration('reading_vocab_meaning'),
                  onChanged: widget.onMeaningChanged,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: ColorsManager.errorColor),
              ),
            ],
          ),
          if (widget.error != null)
            Text(
              appTranslation().get(widget.error!),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.errorColor),
            ),
        ],
      ),
    );
  }
}
