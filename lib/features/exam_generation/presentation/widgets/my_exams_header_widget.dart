import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_generation/presentation/widgets/my_exams_entry_tile.dart';
import 'package:moean/features/exam_generation/presentation/widgets/my_exams_filter_tab.dart';
import 'package:moean/features/exam_generation/presentation/widgets/my_exams_search_field.dart';

class MyExamsHeaderWidget extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onTabChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onExtractExamTap;
  final VoidCallback onDiagnosticTestTap;
  final VoidCallback onNafsTestTap;

  const MyExamsHeaderWidget({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.onSearchChanged,
    required this.onExtractExamTap,
    required this.onDiagnosticTestTap,
    required this.onNafsTestTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyExamsEntryTile(
            icon: Icons.document_scanner_outlined,
            title: appTranslation().get('exam_extract_entry'),
            onTap: onExtractExamTap,
          ),
          verticalSpace8,
          MyExamsEntryTile(
            icon: Icons.track_changes_rounded,
            title: appTranslation().get('diagnostic_title'),
            onTap: onDiagnosticTestTap,
          ),
          verticalSpace8,
          MyExamsEntryTile(
            icon: Icons.track_changes_outlined,
            title: appTranslation().get('national_exams_title'),
            onTap: onNafsTestTap,
          ),
          verticalSpace12,
          MyExamsSearchField(onChanged: onSearchChanged),
          verticalSpace12,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyExamsFilterTab(
                  label: appTranslation().get('all'),
                  isSelected: selectedTab == 'all',
                  onTap: () => onTabChanged('all'),
                ),
                horizontalSpace8,
                MyExamsFilterTab(
                  label: appTranslation().get('draft'),
                  isSelected: selectedTab == 'draft',
                  onTap: () => onTabChanged('draft'),
                ),
                horizontalSpace8,
                MyExamsFilterTab(
                  label: appTranslation().get('published'),
                  isSelected: selectedTab == 'published',
                  onTap: () => onTabChanged('published'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
