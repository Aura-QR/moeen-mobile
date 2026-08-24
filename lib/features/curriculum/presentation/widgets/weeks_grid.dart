import 'package:flutter/material.dart';
import 'package:moean/core/utils/pdf_export_helper.dart';
import 'package:moean/features/curriculum/data/models/curriculum_distribution_models.dart';
import 'export_pdf_card.dart';
import 'week_card.dart';
import 'curriculum_progress_bar.dart';
import 'curriculum_pdf_page.dart';

class WeeksGrid extends StatelessWidget {
  final CurriculumPlanDetailModel detail;
  final CurriculumProgressModel? progress;
  final void Function(int weekId) onPrepareTap;

  const WeeksGrid({
    super.key,
    required this.detail,
    this.progress,
    required this.onPrepareTap,
  });

  static List<Widget> buildSlivers({
    required BuildContext context,
    required CurriculumPlanDetailModel detail,
    CurriculumProgressModel? progress,
    required void Function(int weekId) onPrepareTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 900
        ? 4
        : screenWidth > 600
            ? 3
            : 2;
    final double childAspectRatio = screenWidth > 600 ? 0.85 : 0.80;

    return [
      if (progress != null && progress.totalWeeks > 0)
        SliverToBoxAdapter(child: CurriculumProgressBar(progress: progress)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: childAspectRatio,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, i) => WeekCard(
              week: detail.weeks[i],
              onPrepareTap: onPrepareTap,
            ),
            childCount: detail.weeks.length,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: ExportPdfCard(
          onExport: (school, teacher, manager) async {
            final subjectTitle = detail.plan.subjectName.isNotEmpty
                ? detail.plan.subjectName
                : 'توزيع_المنهج';
            await PdfExportHelper.exportWidgetsToPdfPages(
              context: context,
              title: 'توزيع_${subjectTitle}_${detail.plan.gradeName}',
              pages: buildPdfPages(detail, school, teacher, manager),
            );
          },
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 40)),
    ];
  }

  static List<Widget> buildPdfPages(
    CurriculumPlanDetailModel detail,
    String school,
    String teacher,
    String manager,
  ) {
    final List<Widget> pages = [];
    const int itemsPerPage = 9;
    final int totalPages = (detail.weeks.length / itemsPerPage).ceil().clamp(1, 999);

    for (int i = 0; i < detail.weeks.length; i += itemsPerPage) {
      final int end = (i + itemsPerPage < detail.weeks.length)
          ? i + itemsPerPage
          : detail.weeks.length;
      final weekSubset = detail.weeks.sublist(i, end);
      final int pageNumber = (i ~/ itemsPerPage) + 1;

      pages.add(
        CurriculumPdfPage(
          weeks: weekSubset,
          school: school,
          teacher: teacher,
          manager: manager,
          subjectName: detail.plan.subjectName,
          gradeName: detail.plan.gradeName,
          semester: detail.plan.semester,
          pageNumber: pageNumber,
          totalPages: totalPages,
        ),
      );
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: buildSlivers(
        context: context,
        detail: detail,
        progress: progress,
        onPrepareTap: onPrepareTap,
      ),
    );
  }
}
