import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/pdf_export_helper.dart';
import 'package:moean/features/curriculum/data/models/curriculum_distribution_models.dart';
import 'export_pdf_card.dart';

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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (progress != null)
          SliverToBoxAdapter(child: ProgressBar(progress: progress!)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.82,
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
              await PdfExportHelper.exportWidgetsToPdfPages(
                context: context,
                title: 'توزيع_المناهج_${detail.plan.subjectName}',
                pages: _buildPdfPages(detail, school, teacher, manager),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  List<Widget> _buildPdfPages(
    CurriculumPlanDetailModel detail,
    String school,
    String teacher,
    String manager,
  ) {
    final List<Widget> pages = [];
    const int itemsPerPage = 6;

    for (int i = 0; i < detail.weeks.length; i += itemsPerPage) {
      final int end = (i + itemsPerPage < detail.weeks.length)
          ? i + itemsPerPage
          : detail.weeks.length;
      final weekSubset = detail.weeks.sublist(i, end);

      pages.add(
        Container(
          color: ColorsManager.background,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (school.isNotEmpty)
                    Text('المدرسة: $school',
                        style: TextStylesManager.bold14
                            .copyWith(color: ColorsManager.mainText)),
                  if (teacher.isNotEmpty)
                    Text('المعلم: $teacher',
                        style: TextStylesManager.bold14
                            .copyWith(color: ColorsManager.mainText)),
                  if (manager.isNotEmpty)
                    Text('المدير: $manager',
                        style: TextStylesManager.bold14
                            .copyWith(color: ColorsManager.mainText)),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'توزيع منهج ${detail.plan.subjectName} - ${detail.plan.gradeName}',
                style: TextStylesManager.bold16
                    .copyWith(color: ColorsManager.mainText),
                textAlign: TextAlign.center,
              ),
              verticalSpace16,
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: weekSubset.map((week) {
                  return SizedBox(
                    width: 160,
                    height: 220,
                    child: WeekCard(week: week, onPrepareTap: (_) {}),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    }
    return pages;
  }
}

class ProgressBar extends StatelessWidget {
  final CurriculumProgressModel progress;
  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = progress.status == 'ahead'
        ? Colors.green
        : progress.status == 'behind'
            ? Colors.red
            : ColorsManager.primaryColor;
    final String statusLabel = progress.status == 'ahead'
        ? 'متقدم بـ ${progress.weeksAheadOrBehind} أسبوع'
        : progress.status == 'behind'
            ? 'متأخر بـ ${progress.weeksAheadOrBehind} أسبوع'
            : 'على المسار الصحيح';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            progress.status == 'ahead'
                ? Icons.trending_up
                : progress.status == 'behind'
                    ? Icons.trending_down
                    : Icons.check_circle_outline,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(statusLabel,
              style:
                  TextStylesManager.bold12.copyWith(color: statusColor)),
          const Spacer(),
          Text('${progress.completedWeeks}/${progress.totalWeeks} أسبوع',
              style: TextStylesManager.regular12
                  .copyWith(color: ColorsManager.secondaryText)),
        ],
      ),
    );
  }
}

class WeekCard extends StatelessWidget {
  final CurriculumWeekModel week;
  final void Function(int) onPrepareTap;

  const WeekCard({super.key, required this.week, required this.onPrepareTap});

  @override
  Widget build(BuildContext context) {
    final Color headerColor = week.isHoliday
        ? Colors.orange
        : week.isExam
            ? ColorsManager.errorColor
            : ColorsManager.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: week.isCurrent
              ? ColorsManager.primaryColor
              : ColorsManager.borderLightGray,
          width: week.isCurrent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    week.isHoliday
                        ? (week.title ?? 'إجازة')
                        : week.isExam
                            ? (week.title ?? 'اختبارات')
                            : 'الأسبوع ${week.weekNumber}',
                    style: TextStylesManager.bold12
                        .copyWith(color: Colors.white, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (week.isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('الحالي',
                        style: TextStylesManager.regular12
                            .copyWith(color: Colors.white, fontSize: 9)),
                  ),
              ],
            ),
          ),
          // Gregorian date
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
            child: Text(
              '${week.startsOn} - ${week.endsOn}',
              style: TextStylesManager.regular12
                  .copyWith(color: ColorsManager.secondaryText, fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Hijri date
          if (week.startsOnHijri != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              child: Text(
                '${week.startsOnHijri} - ${week.endsOnHijri}',
                style: TextStylesManager.regular12
                    .copyWith(color: ColorsManager.secondaryText, fontSize: 9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: week.isHoliday || week.isExam
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          week.isHoliday
                              ? Icons.beach_access_rounded
                              : Icons.quiz_outlined,
                          color: headerColor.withOpacity(0.7),
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          week.title ?? '',
                          textAlign: TextAlign.center,
                          style: TextStylesManager.regular12.copyWith(
                            color: headerColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    itemCount: week.items.length,
                    itemBuilder: (_, i) {
                      final item = week.items[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: ColorsManager.primaryColor)),
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStylesManager.regular12.copyWith(
                                    fontSize: 11, height: 1.3),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
