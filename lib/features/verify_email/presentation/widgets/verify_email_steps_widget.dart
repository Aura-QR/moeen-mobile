import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class VerifyEmailStepsWidget extends StatelessWidget {
  const VerifyEmailStepsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE3EFEA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appTranslation().get('verify_email_steps_title'),
            style: TextStylesManager.bold14.copyWith(
              color: const Color(0xFF0A5C49),
            ),
          ),
          verticalSpace10,
          Text(
            appTranslation().get('verify_email_step_1'),
            style: TextStylesManager.regular13.copyWith(
              color: const Color(0xFF556E66),
              height: 1.5,
            ),
          ),
          verticalSpace8,
          Text(
            appTranslation().get('verify_email_step_2'),
            style: TextStylesManager.regular13.copyWith(
              color: const Color(0xFF556E66),
              height: 1.5,
            ),
          ),
          verticalSpace8,
          Text(
            appTranslation().get('verify_email_step_3'),
            style: TextStylesManager.regular13.copyWith(
              color: const Color(0xFF556E66),
              height: 1.5,
            ),
          ),
          verticalSpace8,
          Text(
            appTranslation().get('verify_email_step_4'),
            style: TextStylesManager.regular13.copyWith(
              color: const Color(0xFF556E66),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
