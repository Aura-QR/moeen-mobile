import 'package:moean/features/nafs/presentation/widgets/nafs_badge_widget.dart';
import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';

class ExamListItemWidget extends StatelessWidget {
  final ExamListEntity exam;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onPublish;
  final VoidCallback onDelete;
  final VoidCallback onView;
  final VoidCallback? onShareOnline;

  const ExamListItemWidget({
    super.key,
    required this.exam,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onPublish,
    required this.onDelete,
    required this.onView,
    this.onShareOnline,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? ColorsManager.primaryColor.withValues(alpha: 0.45)
              : ColorsManager.borderLightGray,
          width: isExpanded ? 1.2 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggleExpand,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(18),
                bottom: Radius.circular(isExpanded ? 0 : 18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.assignment_outlined,
                        color: ColorsManager.primaryColor,
                        size: 22,
                      ),
                    ),
                    horizontalSpace12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam.title,
                            maxLines: isExpanded ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStylesManager.bold14.copyWith(
                              color: ColorsManager.mainText,
                            ),
                          ),
                          verticalSpace6,
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _buildStatusBadge(),
                              if (exam.kind == 'diagnostic') _buildDiagnosticBadge(),
                              if (exam.kind == 'nafs') const NafsBadgeWidget(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    horizontalSpace8,
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isExpanded
                              ? ColorsManager.primaryColor.withValues(alpha: 0.1)
                              : ColorsManager.background,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: isExpanded
                              ? ColorsManager.primaryColor
                              : ColorsManager.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Divider(color: ColorsManager.borderLightGray, height: 1),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildDetailItem(
                                  icon: Icons.help_outline_rounded,
                                  label: appTranslation().get('questions_count'),
                                  value: '${exam.questionsCount}',
                                ),
                                horizontalSpace8,
                                _buildDetailItem(
                                  icon: Icons.workspace_premium_outlined,
                                  label: appTranslation().get('grade'),
                                  value: '${exam.totalPoints}',
                                ),
                                horizontalSpace8,
                                _buildDetailItem(
                                  icon: Icons.calendar_today_outlined,
                                  label: appTranslation().get('last_update'),
                                  value: _formatDate(exam.updatedAt),
                                ),
                              ],
                            ),
                            verticalSpace14,
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildActionButton(
                                  title: appTranslation().get('view'),
                                  icon: Icons.visibility_outlined,
                                  textColor: ColorsManager.primaryColor,
                                  iconColor: ColorsManager.primaryColor,
                                  backgroundColor:
                                      ColorsManager.primaryColor.withValues(alpha: 0.08),
                                  border: Border.all(
                                    color: ColorsManager.primaryColor.withValues(alpha: 0.35),
                                  ),
                                  onTap: onView,
                                ),
                                if (exam.status == 'draft')
                                  _buildActionButton(
                                    title: appTranslation().get('publish'),
                                    icon: Icons.check_circle_outline,
                                    textColor: Colors.white,
                                    iconColor: Colors.white,
                                    backgroundColor: ColorsManager.primaryColor,
                                    onTap: onPublish,
                                  ),
                                if (onShareOnline != null)
                                  _buildActionButton(
                                    title: appTranslation().get('online_tests_share'),
                                    icon: Icons.qr_code_2,
                                    textColor: ColorsManager.primaryColor,
                                    iconColor: ColorsManager.primaryColor,
                                    backgroundColor:
                                        ColorsManager.primaryColor.withValues(alpha: 0.08),
                                    border: Border.all(
                                      color: ColorsManager.primaryColor.withValues(alpha: 0.35),
                                    ),
                                    onTap: onShareOnline!,
                                  ),
                                _buildActionButton(
                                  title: appTranslation().get('delete'),
                                  icon: Icons.delete_outline,
                                  textColor: Colors.red,
                                  iconColor: Colors.red,
                                  backgroundColor: Colors.red.withValues(alpha: 0.08),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.25),
                                  ),
                                  onTap: onDelete,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: ColorsManager.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorsManager.borderLightGray),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: ColorsManager.primaryColor),
            verticalSpace4,
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStylesManager.regular12.copyWith(
                color: ColorsManager.secondaryText,
              ),
            ),
            verticalSpace4,
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStylesManager.bold13.copyWith(
                color: ColorsManager.mainText,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  Widget _buildDiagnosticBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ColorsManager.secondaryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        appTranslation().get('diagnostic_tag'),
        style: TextStylesManager.medium12.copyWith(
          color: ColorsManager.secondaryColor,
        ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: iconColor),
              horizontalSpace6,
              Text(
                title,
                style: TextStylesManager.bold12.copyWith(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}/${date.month}/${date.day}';
    } catch (_) {
      return dateStr;
    }
  }
}
