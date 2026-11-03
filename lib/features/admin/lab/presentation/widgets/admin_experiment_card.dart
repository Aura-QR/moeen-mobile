import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/lab/data/models/admin_lab_models.dart';
import 'package:moean/features/admin/lab/presentation/cubit/admin_lab_cubit.dart';
import 'package:moean/features/admin/lab/presentation/widgets/admin_lab_status_badge.dart';

class AdminExperimentCard extends StatelessWidget {
  final AdminLabExperimentModel experiment;

  const AdminExperimentCard({super.key, required this.experiment});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminLabCubit.get(context);

    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: experiment.openReportsCount > 0
              ? ColorsManager.errorColor.withValues(alpha: 0.5)
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(experiment.name, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                    verticalSpace4,
                    Text(experiment.key, style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  experiment.featured ? Icons.star_rounded : Icons.star_border_rounded,
                  color: experiment.featured ? ColorsManager.goldDark : ColorsManager.secondaryText,
                ),
                onPressed: () => cubit.toggleFeatureExperiment(experiment),
              ),
            ],
          ),
          verticalSpace8,
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              AdminLabStatusBadge(
                label: experiment.isPublished
                    ? appTranslation().get('admin_lab_published')
                    : appTranslation().get('admin_lab_hidden'),
                isGreen: experiment.isPublished,
              ),
              AdminLabStatusBadge(
                label: experiment.isCommunity
                    ? appTranslation().get('admin_lab_community')
                    : appTranslation().get('admin_lab_hader'),
                isGreen: !experiment.isCommunity,
              ),
              if (experiment.isCommunity)
                AdminLabStatusBadge(
                  label: experiment.approved
                      ? appTranslation().get('admin_lab_approved')
                      : appTranslation().get('admin_lab_unapproved'),
                  isGreen: experiment.approved,
                ),
              if (experiment.openReportsCount > 0)
                AdminLabStatusBadge(
                  label: appTranslation()
                      .get('admin_lab_reports_count')
                      .replaceAll('{count}', experiment.openReportsCount.toString()),
                  isGreen: false,
                  isAlert: true,
                ),
            ],
          ),
          if (experiment.authorName != null && experiment.authorName!.isNotEmpty) ...[
            verticalSpace8,
            Text(
              appTranslation().get('admin_lab_teacher').replaceAll('{name}', experiment.authorName!),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
          ],
          verticalSpace12,
          Row(
            children: [
              if (experiment.isCommunity) ...[
                OutlinedButton(
                  onPressed: () => cubit.toggleApproveExperiment(experiment),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: experiment.approved ? ColorsManager.errorColor : ColorsManager.successColor,
                    side: BorderSide(color: experiment.approved ? ColorsManager.errorColor : ColorsManager.successColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    experiment.approved ? appTranslation().get('admin_lab_unapproved') : appTranslation().get('admin_lab_approve'),
                    style: TextStylesManager.bold12,
                  ),
                ),
                horizontalSpace8,
              ],
              OutlinedButton(
                onPressed: () => cubit.togglePublishExperiment(experiment),
                style: OutlinedButton.styleFrom(
                  foregroundColor: experiment.isPublished ? ColorsManager.errorColor : ColorsManager.primaryColor,
                  side: BorderSide(color: experiment.isPublished ? ColorsManager.errorColor : ColorsManager.primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  experiment.isPublished ? appTranslation().get('admin_lab_hide') : appTranslation().get('admin_lab_publish'),
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
