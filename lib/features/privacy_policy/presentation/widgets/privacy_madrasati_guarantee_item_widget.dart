import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class PrivacyMadrasatiGuaranteeItemWidget extends StatelessWidget {
  final String text;
  final String emoji;

  const PrivacyMadrasatiGuaranteeItemWidget({
    super.key,
    required this.text,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        horizontalSpace8,
        Expanded(
          child: Text(
            text,
            style: TextStylesManager.regular12.copyWith(
              color: ColorsManager.mainText,
              height: 1.5,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
