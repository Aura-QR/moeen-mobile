import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class PrivacyAiCheckItemWidget extends StatelessWidget {
  final String text;

  const PrivacyAiCheckItemWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          color: ColorsManager.primaryColor,
          size: 20,
        ),
        horizontalSpace10,
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
      ],
    );
  }
}
