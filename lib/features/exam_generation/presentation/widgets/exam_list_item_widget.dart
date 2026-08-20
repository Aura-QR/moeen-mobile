import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';

class ExamListItemWidget extends StatelessWidget {
  final ExamListEntity exam;
  final double colTitle;
  final double colStatus;
  final double colQuestions;
  final double colGrade;
  final double colDate;
  final double colActions;
  final VoidCallback onPublish;
  final VoidCallback onDelete;
  final VoidCallback onView;
  final VoidCallback? onTap;

  const ExamListItemWidget({
    super.key,
    required this.exam,
    required this.colTitle,
    required this.colStatus,
    required this.colQuestions,
    required this.colGrade,
    required this.colDate,
    required this.colActions,
    required this.onPublish,
    required this.onDelete,
    required this.onView,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? onView,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Row(
          children: [
            SizedBox(
              width: colTitle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    exam.title,
                    style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: colStatus,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: _buildStatusBadge(),
                ),
              ),
            ),
            SizedBox(
              width: colQuestions,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    '${exam.questionsCount}',
                    style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: colGrade,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    '${exam.totalPoints}',
                    style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: colDate,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    _formatDate(exam.updatedAt),
                    style: TextStylesManager.medium14.copyWith(color: ColorsManager.secondaryText),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: colActions,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      title: appTranslation().get('view'),
                      icon: Icons.visibility_outlined,
                      textColor: ColorsManager.primaryColor,
                      iconColor: ColorsManager.primaryColor,
                      backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.06),
                      border: Border.all(color: ColorsManager.primaryColor.withValues(alpha: 0.35)),
                      onTap: onView,
                    ),
                    if (exam.status == 'draft') ...[
                      horizontalSpace6,
                      _buildActionButton(
                        title: appTranslation().get('publish'),
                        icon: Icons.check_circle_outline,
                        textColor: Colors.white,
                        iconColor: Colors.white,
                        backgroundColor: ColorsManager.primaryColor,
                        onTap: onPublish,
                      ),
                    ],
                    horizontalSpace6,
                    _buildActionButton(
                      title: appTranslation().get('delete'),
                      icon: Icons.delete_outline,
                      textColor: Colors.red,
                      iconColor: Colors.red,
                      backgroundColor: Colors.red.withValues(alpha: 0.08),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isPublished = exam.status == 'published';
    final color = isPublished ? ColorsManager.primaryColor : ColorsManager.secondaryText;
    final text = appTranslation().get(isPublished ? 'published' : 'draft');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStylesManager.medium12.copyWith(color: color),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color textColor,
    required Color iconColor,
    required Color backgroundColor,
    Border? border,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStylesManager.bold12.copyWith(color: textColor)),
            horizontalSpace4,
            Icon(icon, size: 16, color: iconColor),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}/${date.month}/${date.day}';
    } catch (_) {
      return dateStr;
    }
  }
}
