import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class PrivacyCookieBulletWidget extends StatelessWidget {
  final String text;

  const PrivacyCookieBulletWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        horizontalSpace10,
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: ColorsManager.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
