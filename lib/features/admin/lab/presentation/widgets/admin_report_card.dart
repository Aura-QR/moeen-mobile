import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/lab/data/models/admin_lab_models.dart';
import 'package:moean/features/admin/lab/presentation/cubit/admin_lab_cubit.dart';
import 'package:moean/features/admin/lab/presentation/widgets/admin_lab_status_badge.dart';

class AdminReportCard extends StatelessWidget {
  final AdminLabMistakeReportModel report;

  const AdminReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminLabCubit.get(context);

    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: report.isOpen
              ? ColorsManager.errorColor.withValues(alpha: 0.4)
              : ColorsManager.borderLightGray,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.experimentName ?? report.experimentKey ?? '',
                  style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                ),
              ),
              AdminLabStatusBadge(
                label: report.isOpen
                    ? appTranslation().get('admin_lab_status_open')
                    : appTranslation().get('admin_lab_status_done'),
                isGreen: !report.isOpen,
                isAlert: report.isOpen,
              ),
            ],
          ),
          verticalSpace8,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorsManager.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              report.message,
              style: TextStylesManager.regular13.copyWith(color: ColorsManager.mainText),
            ),
          ),
          if (report.teacherName != null && report.teacherName!.isNotEmpty) ...[
            verticalSpace8,
            Text(
              appTranslation().get('admin_lab_teacher').replaceAll('{name}', report.teacherName!),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
          ],
          verticalSpace12,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => cubit.toggleReportStatus(report),
                style: OutlinedButton.styleFrom(
                  foregroundColor: report.isOpen ? ColorsManager.successColor : ColorsManager.placeholder,
                  side: BorderSide(
                    color: report.isOpen ? ColorsManager.successColor : ColorsManager.placeholder,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  report.isOpen
                      ? appTranslation().get('admin_lab_mark_done')
                      : appTranslation().get('admin_lab_mark_open'),
                  style: TextStylesManager.bold12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
