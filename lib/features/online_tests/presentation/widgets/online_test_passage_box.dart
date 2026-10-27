import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// Mirrors `dir="auto"`: Arabic reads right to left, anything else left to right.
TextDirection _directionOf(String text) =>
    RegExp(r'[؀-ۿ]').hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;

/// L12 «الفهم القرائي»: the reading passage shown above the questions on the
/// teacher's online test screen. Collapsible, numbered, and `dir=auto` so an
/// English passage reads left to right.
class OnlineTestPassageBox extends StatefulWidget {
  final List<String> paragraphs;

  const OnlineTestPassageBox({super.key, required this.paragraphs});

  @override
  State<OnlineTestPassageBox> createState() => _OnlineTestPassageBoxState();
}

class _OnlineTestPassageBoxState extends State<OnlineTestPassageBox> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Icon(Icons.menu_book_outlined, size: 20, color: ColorsManager.primaryColor),
                horizontalSpace8,
                Expanded(
                  child: Text(
                    appTranslation().get('reading_passage_label'),
                    style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: ColorsManager.secondaryText,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            verticalSpace10,
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < widget.paragraphs.length; i++) ...[
                      if (i > 0) verticalSpace8,
                      Text(
                        '${i + 1}. ${widget.paragraphs[i]}',
                        textDirection: _directionOf(widget.paragraphs[i]),
                        style: TextStylesManager.regular13.copyWith(
                          color: ColorsManager.textBody,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
