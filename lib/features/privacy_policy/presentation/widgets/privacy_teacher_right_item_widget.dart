import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class PrivacyTeacherRightItemWidget extends StatelessWidget {
  final int number;
  final String text;

  const PrivacyTeacherRightItemWidget({
    super.key,
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStylesManager.regular13.copyWith(
                color: ColorsManager.mainText,
                height: 1.5,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          horizontalSpace12,
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$number',
              style: TextStylesManager.bold14.copyWith(
                color: ColorsManager.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
