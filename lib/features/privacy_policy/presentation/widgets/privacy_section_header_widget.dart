import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_tag_badge_widget.dart';

class PrivacySectionHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String tag;

  const PrivacySectionHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStylesManager.bold18.copyWith(
                      color: ColorsManager.primaryColor,
                    ),
                  ),
                  verticalSpace4,
                  Text(
                    subtitle,
                    style: TextStylesManager.regular12.copyWith(
                      color: ColorsManager.placeholder,
                    ),
                  ),
                ],
              ),
            ),
            horizontalSpace8,
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: ColorsManager.primaryColor,
                size: 22,
              ),
            ),
          ],
        ),
        verticalSpace12,
        Align(
          alignment: Alignment.centerLeft,
          child: PrivacyTagBadgeWidget(label: tag),
        ),
        verticalSpace12,
        Divider(
          color: ColorsManager.borderColor,
          thickness: 1,
        ),
      ],
    );
  }
}
