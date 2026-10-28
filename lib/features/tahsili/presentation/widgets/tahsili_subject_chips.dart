import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/features/tahsili/data/models/tahsili_models.dart';
import 'package:moean/features/tahsili/presentation/cubit/tahsili_cubit.dart';

class TahsiliSubjectChips extends StatelessWidget {
  final List<TahsiliSubjectOption> subjects;
  final TahsiliSubjectOption? selectedSubject;

  const TahsiliSubjectChips({
    super.key,
    required this.subjects,
    required this.selectedSubject,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = TahsiliCubit.get(context);

    return PrimarySectionCard(
      icon: Icons.menu_book_outlined,
      title: appTranslation().get('tahsili_choose_subject'),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: subjects.map((subj) {
          final isSelected = subj.id == selectedSubject?.id;
          return ChoiceChip(
            label: Text(
              subj.name,
              style: TextStylesManager.bold13.copyWith(
                color: isSelected ? ColorsManager.surfacePrimary : ColorsManager.mainText,
              ),
            ),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: ColorsManager.primaryColor,
            backgroundColor: ColorsManager.surfacePrimary,
            side: BorderSide(
              color: isSelected ? ColorsManager.primaryColor : ColorsManager.borderLightGray,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (_) => cubit.selectSubject(subj),
          );
        }).toList(),
      ),
    );
  }
}
