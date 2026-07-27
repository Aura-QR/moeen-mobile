import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/data/saved_report_model.dart';

class SavedReportCardWidget extends StatelessWidget {
  final SavedReportModel report;
  final VoidCallback onOpen;

  const SavedReportCardWidget({
    super.key,
    required this.report,
    required this.onOpen,
  });

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateStr);
      final months = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (_) {
      return dateStr.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(report.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorsManager.borderColor.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: File icon & Report type badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFFD97706),
                  size: 24,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  report.reportType,
                  style: TextStylesManager.bold12.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace16,

          // Report Title
          Text(
            report.displaySubject,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStylesManager.bold16.copyWith(
              color: ColorsManager.mainText,
              height: 1.3,
            ),
          ),
          verticalSpace6,

          // Report Subtitle (Grade)
          Text(
            report.grade,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStylesManager.regular14.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
          verticalSpace16,

          // Meta Row (Lessons count & Date)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorsManager.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${report.selectedLessons.length} درس',
                  style: TextStylesManager.bold12.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                ),
              ),
              horizontalSpace8,
              if (formattedDate.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorsManager.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 14,
                        color: ColorsManager.secondaryText,
                      ),
                      horizontalSpace4,
                      Text(
                        formattedDate,
                        style: TextStylesManager.bold12.copyWith(
                          color: ColorsManager.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          verticalSpace16,

          // Open Report Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onOpen,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.visibility_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  horizontalSpace8,
                  Text(
                    appTranslation().get('open_report_btn'),
                    style: TextStylesManager.bold14.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
