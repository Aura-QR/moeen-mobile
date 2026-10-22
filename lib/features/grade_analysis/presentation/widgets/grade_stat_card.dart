import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// One indicator, e.g. «المتوسط»: its value large, a detail under it.
class GradeStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? detail;

  const GradeStatCard({super.key, required this.icon, required this.label, required this.value, this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: ColorsManager.primaryColor),
              horizontalSpace6,
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStylesManager.medium12.copyWith(color: ColorsManager.secondaryText),
                ),
              ),
            ],
          ),
          verticalSpace6,
          Text(value, style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText)),
          if (detail != null)
            Text(detail!, style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
        ],
      ),
    );
  }
}
