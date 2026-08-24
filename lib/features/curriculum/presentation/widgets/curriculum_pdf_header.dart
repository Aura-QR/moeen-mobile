import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class CurriculumPdfHeader extends StatelessWidget {
  final String school;
  final String teacher;
  final String manager;
  final String subjectName;
  final String gradeName;
  final int semester;

  const CurriculumPdfHeader({
    super.key,
    required this.school,
    required this.teacher,
    required this.manager,
    required this.subjectName,
    required this.gradeName,
    required this.semester,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> titleParts = [];
    if (subjectName.isNotEmpty) titleParts.add(subjectName);
    if (gradeName.isNotEmpty) titleParts.add(gradeName);
    titleParts.add('الفصل الدراسي $semester');

    final String titleText = titleParts.join('  •  ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorsManager.primaryColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PdfHeaderInfoPill(
                label: 'المدرسة',
                value: school.isEmpty ? '—' : school,
                icon: Icons.account_balance_outlined,
              ),
              PdfHeaderInfoPill(
                label: 'المعلم /ة',
                value: teacher.isEmpty ? '—' : teacher,
                icon: Icons.person_outline,
              ),
              PdfHeaderInfoPill(
                label: 'المدير /ة',
                value: manager.isEmpty ? '—' : manager,
                icon: Icons.assignment_ind_outlined,
              ),
            ],
          ),
          verticalSpace10,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'توزيع الخطة الدراسية : $titleText',
              style: TextStylesManager.bold14.copyWith(
                color: Colors.white,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class PdfHeaderInfoPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const PdfHeaderInfoPill({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ColorsManager.primaryColor),
          horizontalSpace6,
          Text(
            '$label: ',
            style: TextStylesManager.bold12.copyWith(
              color: ColorsManager.secondaryText,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: TextStylesManager.bold12.copyWith(
              color: ColorsManager.mainText,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
