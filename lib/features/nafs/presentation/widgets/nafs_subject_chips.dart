import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/nafs/data/models/nafs_models.dart';
import 'package:moean/features/nafs/presentation/cubit/nafs_cubit.dart';

class NafsSubjectChips extends StatelessWidget {
  final List<NafsSubjectOption> subjects;
  final NafsSubjectOption? selectedSubject;

  const NafsSubjectChips({
    super.key,
    required this.subjects,
    required this.selectedSubject,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = NafsCubit.get(context);

    return PrimarySectionCard(
      icon: Icons.menu_book_outlined,
      title: appTranslation().get('nafs_choose_subject'),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final subject in subjects)
            _SubjectChipItem(
              subject: subject,
              isSelected: selectedSubject?.id == subject.id,
              onTap: () => cubit.selectSubject(subject),
            ),
        ],
      ),
    );
  }
}

class _SubjectChipItem extends StatelessWidget {
  final NafsSubjectOption subject;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubjectChipItem({
    required this.subject,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? ColorsManager.primaryColor : ColorsManager.background;
    final textColor = isSelected ? ColorsManager.surfacePrimary : ColorsManager.mainText;
    final borderColor = isSelected ? ColorsManager.primaryColor : ColorsManager.borderLightGray;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: textColor,
              ),
              horizontalSpace8,
              Text(
                subject.name,
                style: TextStylesManager.bold13.copyWith(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
