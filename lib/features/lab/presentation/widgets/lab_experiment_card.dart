import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';
import 'package:moean/features/lab/presentation/widgets/lab_approximate_badge.dart';
import 'package:moean/features/lab/presentation/widgets/lab_experiment_footer_row.dart';

class LabExperimentCard extends StatelessWidget {
  final LabExperimentModel experiment;
  final VoidCallback onTap;

  const LabExperimentCard({
    super.key,
    required this.experiment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorsManager.borderLightGray),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.science_outlined,
                    color: ColorsManager.primaryColor,
                    size: 24,
                  ),
                ),
                horizontalSpace12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        experiment.name,
                        style: TextStylesManager.bold14.copyWith(
                          color: ColorsManager.mainText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (experiment.area.isNotEmpty) ...[
                        verticalSpace4,
                        Text(
                          experiment.area,
                          style: TextStylesManager.regular12.copyWith(
                            color: ColorsManager.secondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (experiment.approximate) const LabApproximateBadge(),
              ],
            ),
            if (experiment.observe.isNotEmpty) ...[
              verticalSpace10,
              Text(
                experiment.observe,
                style: TextStylesManager.regular12.copyWith(
                  color: ColorsManager.secondaryText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            verticalSpace12,
            LabExperimentFooterRow(
              lessonsCount: experiment.lessonsCount,
              plays: experiment.plays,
            ),
          ],
        ),
      ),
    );
  }
}
