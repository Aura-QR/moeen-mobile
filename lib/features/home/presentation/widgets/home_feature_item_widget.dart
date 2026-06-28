import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class HomeFeatureItemWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const HomeFeatureItemWidget({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12), 
        decoration: BoxDecoration(
          color: isHighlighted
              ? ColorsManager.goldMedium.withValues(alpha: 0.02)
              : ColorsManager.surfacePrimary, 
          border: Border.all(
            color: isHighlighted
                ? ColorsManager.goldMedium.withValues(alpha: 0.6) 
                : ColorsManager.primaryColor.withValues(alpha: 0.2), 
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isHighlighted 
                    ? ColorsManager.goldMedium.withValues(alpha: 0.1) 
                    : iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon, 
                color: isHighlighted ? ColorsManager.goldMedium : iconColor, 
                size: 20, 
              ),
            ),
            horizontalSpace6,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStylesManager.bold16.copyWith(
                      color: isHighlighted
                          ? ColorsManager.goldMedium
                          : ColorsManager.mainText,
                      fontSize: 12, 
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpace4,
                  Text(
                    subtitle,
                    style: TextStylesManager.regular14.copyWith(
                      color: ColorsManager.secondaryText,
                      fontSize: 9,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}