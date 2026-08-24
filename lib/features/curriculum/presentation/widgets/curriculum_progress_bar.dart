import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/curriculum/data/models/curriculum_distribution_models.dart';

class CurriculumProgressBar extends StatelessWidget {
  final CurriculumProgressModel progress;
  const CurriculumProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = progress.status == 'ahead'
        ? ColorsManager.successColor
        : progress.status == 'behind'
            ? ColorsManager.errorColor
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
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
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
          Text(
            statusLabel,
            style: TextStylesManager.bold12.copyWith(color: statusColor),
          ),
          const Spacer(),
          Text(
            '${progress.completedWeeks}/${progress.totalWeeks} أسبوع',
            style: TextStylesManager.regular12.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
