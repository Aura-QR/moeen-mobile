import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// A template to start from, or a saved report to reopen.
class ReportTemplateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ReportTemplateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ColorsManager.borderLightGray),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: ColorsManager.primaryColor),
                ),
                horizontalSpace12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                      if (subtitle.isNotEmpty) ...[
                        verticalSpace4,
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_left_rounded, color: ColorsManager.secondaryText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
