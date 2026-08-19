import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class VerifyEmailHeaderWidget extends StatelessWidget {
  final String email;

  const VerifyEmailHeaderWidget({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          appTranslation().get('verify_email_title'),
          style: TextStylesManager.bold26.copyWith(
            color: const Color(0xFF0A5C49),
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpace8,
        Text(
          appTranslation().get('verify_email_subtitle'),
          style: TextStylesManager.regular14.copyWith(
            color: ColorsManager.placeholder,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpace12,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD5EAE2),
            ),
          ),
          child: Text(
            email,
            style: TextStylesManager.bold16.copyWith(
              color: const Color(0xFF0E7A5E),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
