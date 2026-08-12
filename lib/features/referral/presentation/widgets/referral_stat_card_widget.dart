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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorsManager.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                horizontalSpace8,
                Expanded(
                  child: Text(
                    label,
                    style: TextStylesManager.regular12.copyWith(
                      color: ColorsManager.textSecondary,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            verticalSpace12,
            Text(
              value,
              style: TextStylesManager.bold16.copyWith(
                color: ColorsManager.textPrimary,
              ),
              textAlign: TextAlign.start,
            ),
            if (hint != null) ...[
              verticalSpace4,
              Text(
                hint!,
                style: TextStylesManager.regular12.copyWith(
                  color: ColorsManager.textSecondary,
                  fontSize: 10,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
