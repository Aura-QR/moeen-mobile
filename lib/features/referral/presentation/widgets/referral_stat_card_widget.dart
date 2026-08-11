import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ReferralStatCardWidget extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const ReferralStatCardWidget({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          horizontalSpace16,
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: TextStylesManager.regular13.copyWith(
                    color: ColorsManager.textSecondary,
                  ),
                ),
                verticalSpace4,
                Text(
                  value,
                  style: TextStylesManager.bold20.copyWith(
                    color: ColorsManager.textPrimary,
                  ),
                ),
                if (hint != null) ...[
                  verticalSpace2,
                  Text(
                    hint!,
                    style: TextStylesManager.regular12.copyWith(
                      color: ColorsManager.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
