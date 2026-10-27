import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/nafs/data/models/nafs_models.dart';
import 'package:moean/features/nafs/presentation/cubit/nafs_cubit.dart';

class NafsGradeChips extends StatelessWidget {
  final List<NafsGradeOption> grades;
  final NafsGradeOption? selectedGrade;

  const NafsGradeChips({
    super.key,
    required this.grades,
    required this.selectedGrade,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = NafsCubit.get(context);

    return PrimarySectionCard(
      icon: Icons.school_outlined,
      title: appTranslation().get('nafs_choose_grade'),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final grade in grades)
            _GradeChipItem(
              grade: grade,
              isSelected: selectedGrade?.id == grade.id,
              onTap: () => cubit.selectGrade(grade),
            ),
        ],
      ),
    );
  }
}

class _GradeChipItem extends StatelessWidget {
  final NafsGradeOption grade;
  final bool isSelected;
  final VoidCallback onTap;

  const _GradeChipItem({
    required this.grade,
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
                grade.name,
                style: TextStylesManager.bold13.copyWith(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
