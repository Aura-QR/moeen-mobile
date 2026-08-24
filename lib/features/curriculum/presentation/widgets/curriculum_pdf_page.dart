import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/curriculum/data/models/curriculum_distribution_models.dart';
import 'curriculum_pdf_header.dart';
import 'curriculum_pdf_footer.dart';
import 'week_card.dart';

class CurriculumPdfPage extends StatelessWidget {
  final List<CurriculumWeekModel> weeks;
  final String school;
  final String teacher;
  final String manager;
  final String subjectName;
  final String gradeName;
  final int semester;
  final int pageNumber;
  final int totalPages;

  const CurriculumPdfPage({
    super.key,
    required this.weeks,
    required this.school,
    required this.teacher,
    required this.manager,
    required this.subjectName,
    required this.gradeName,
    required this.semester,
    required this.pageNumber,
    required this.totalPages,
  });

  Widget _buildRow(List<CurriculumWeekModel> rowWeeks) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: rowWeeks.isNotEmpty
                ? WeekCard(week: rowWeeks[0], isForPdf: true)
                : const SizedBox.shrink(),
          ),
          horizontalSpace12,
          Expanded(
            child: rowWeeks.length > 1
                ? WeekCard(week: rowWeeks[1], isForPdf: true)
                : const SizedBox.shrink(),
          ),
          horizontalSpace12,
          Expanded(
            child: rowWeeks.length > 2
                ? WeekCard(week: rowWeeks[2], isForPdf: true)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final row1Weeks = weeks.sublist(0, weeks.length >= 3 ? 3 : weeks.length);
    final row2Weeks = weeks.length > 3
        ? weeks.sublist(3, weeks.length >= 6 ? 6 : weeks.length)
        : <CurriculumWeekModel>[];
    final row3Weeks = weeks.length > 6
        ? weeks.sublist(6, weeks.length >= 9 ? 9 : weeks.length)
        : <CurriculumWeekModel>[];

    return Container(
      width: 840,
      height: 1188,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CurriculumPdfHeader(
            school: school,
            teacher: teacher,
            manager: manager,
            subjectName: subjectName,
            gradeName: gradeName,
            semester: semester,
          ),
          verticalSpace12,
          Expanded(
            child: Column(
              children: [
                _buildRow(row1Weeks),
                verticalSpace10,
                _buildRow(row2Weeks),
                verticalSpace10,
                _buildRow(row3Weeks),
              ],
            ),
          ),
          verticalSpace12,
          CurriculumPdfFooter(
            pageNumber: pageNumber,
            totalPages: totalPages,
          ),
        ],
      ),
    );
  }
}
