import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/curriculum/data/models/curriculum_distribution_models.dart';

class WeekCard extends StatelessWidget {
  final CurriculumWeekModel week;
  final void Function(int weekId)? onPrepareTap;
  final bool isForPdf;

  const WeekCard({
    super.key,
    required this.week,
    this.onPrepareTap,
    this.isForPdf = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color headerColor = week.isHoliday
        ? ColorsManager.statusWarning
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
        boxShadow: isForPdf
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
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
                            : 'الأسبوع ${week.weekNumber ?? ''}',
                    style: TextStylesManager.bold12.copyWith(
                      color: Colors.white,
                      fontSize: isForPdf ? 12 : 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (week.isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'الحالي',
                      style: TextStylesManager.regular12.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Gregorian date
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
            child: Text(
              '${week.startsOn} - ${week.endsOn}',
              style: TextStylesManager.regular12.copyWith(
                color: ColorsManager.secondaryText,
                fontSize: isForPdf ? 10 : 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Hijri date
          if (week.startsOnHijri != null && week.startsOnHijri!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              child: Text(
                '${week.startsOnHijri} - ${week.endsOnHijri ?? ''}',
                style: TextStylesManager.regular12.copyWith(
                  color: ColorsManager.secondaryText,
                  fontSize: isForPdf ? 10 : 9,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          const Divider(height: 1),

          // Content body
          Expanded(
            child: week.isHoliday || week.isExam
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            week.isHoliday
                                ? Icons.beach_access_rounded
                                : Icons.quiz_outlined,
                            color: headerColor.withValues(alpha: 0.7),
                            size: isForPdf ? 34 : 28,
                          ),
                          verticalSpace6,
                          Text(
                            week.title ?? (week.isHoliday ? 'إجازة' : 'اختبارات'),
                            textAlign: TextAlign.center,
                            style: TextStylesManager.bold12.copyWith(
                              color: headerColor,
                              fontSize: isForPdf ? 12 : 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : (isForPdf
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: week.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: ColorsManager.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStylesManager.regular12.copyWith(
                                        color: ColorsManager.mainText,
                                        fontSize: 11,
                                        height: 1.3,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        itemCount: week.items.length,
                        itemBuilder: (_, i) {
                          final item = week.items[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: ColorsManager.primaryColor,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: TextStylesManager.regular12.copyWith(
                                      fontSize: 11,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )),
          ),
        ],
      ),
    );
  }
}
