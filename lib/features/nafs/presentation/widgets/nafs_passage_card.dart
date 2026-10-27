import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/nafs/presentation/cubit/nafs_cubit.dart';

class NafsPassageCard extends StatefulWidget {
  final String passage;

  const NafsPassageCard({
    super.key,
    required this.passage,
  });

  @override
  State<NafsPassageCard> createState() => _NafsPassageCardState();
}

class _NafsPassageCardState extends State<NafsPassageCard> {
  late final TextEditingController _controller = TextEditingController(text: widget.passage);
  bool _expanded = true;

  @override
  void didUpdateWidget(covariant NafsPassageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.passage != widget.passage && _controller.text != widget.passage) {
      _controller.text = widget.passage;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = NafsCubit.get(context);

    return PrimarySectionCard(
      icon: Icons.menu_book_rounded,
      title: appTranslation().get('nafs_reading_passage_label'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      appTranslation().get('nafs_passage_title'),
                      style: TextStylesManager.bold13.copyWith(color: ColorsManager.primaryColor),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: ColorsManager.secondaryText,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            verticalSpace8,
            PrimaryTextField(
              controller: _controller,
              hint: appTranslation().get('nafs_reading_passage_hint'),
              maxLines: 6,
              onChanged: cubit.setPassage,
            ),
          ],
        ],
      ),
    );
  }
}
