import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';

/// Writing progress, post-generation review/undo banner, failure+retry banner, or 429 limit notice.
class ReportRoleAiStatusBanner extends StatelessWidget {
  final RoleAiStatus status;
  final String? errorMessage;
  final bool canUndo;
  final VoidCallback onUndo;
  final VoidCallback onRetry;

  const ReportRoleAiStatusBanner({
    super.key,
    required this.status,
    required this.errorMessage,
    required this.canUndo,
    required this.onUndo,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (status == RoleAiStatus.writing) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 14, height: 14),
              child: CircularProgressIndicator(strokeWidth: 2, color: ColorsManager.primaryColor),
            ),
            horizontalSpace8,
            Text(
              appTranslation().get('role_ai_writing'),
              style: TextStylesManager.medium12.copyWith(color: ColorsManager.primaryColor),
            ),
          ],
        ),
      );
    }

    if (status == RoleAiStatus.done) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: ColorsManager.successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ColorsManager.successColor.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 18, color: ColorsManager.successColor),
              horizontalSpace8,
              Expanded(
                child: Text(
                  appTranslation().get('role_ai_review_notice'),
                  style: TextStylesManager.medium12.copyWith(color: ColorsManager.mainText),
                ),
              ),
              if (canUndo)
                TextButton(
                  onPressed: onUndo,
                  child: Text(
                    appTranslation().get('role_ai_undo'),
                    style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (status == RoleAiStatus.failed || status == RoleAiStatus.rateLimited) {
      final isLimit = status == RoleAiStatus.rateLimited;
      final tone = isLimit ? ColorsManager.statusWarning : ColorsManager.errorColor;
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tone.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(
                isLimit ? Icons.hourglass_bottom_rounded : Icons.error_outline_rounded,
                size: 18,
                color: tone,
              ),
              horizontalSpace8,
              Expanded(
                child: Text(
                  appTranslation().get(errorMessage ?? 'role_ai_failed'),
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.mainText),
                ),
              ),
              if (!isLimit)
                TextButton(
                  onPressed: onRetry,
                  child: Text(
                    appTranslation().get('retry'),
                    style: TextStylesManager.bold12.copyWith(color: tone),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return const Offstage();
  }
}
