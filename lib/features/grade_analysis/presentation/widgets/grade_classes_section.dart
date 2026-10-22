import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_active_class.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_class_tabs.dart';

/// «الفصول»: 1 to 5 classes, one tab each. Two or more make a comparison.
class GradeClassesSection extends StatelessWidget {
  const GradeClassesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimarySectionCard(
      icon: Icons.groups_2_outlined,
      title: appTranslation().get('grades_section_classes'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [const GradeClassTabs(), verticalSpace12, const GradeActiveClass()],
      ),
    );
  }
}
