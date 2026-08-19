import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';

class PrivacySupportCardWidget extends StatelessWidget {
  const PrivacySupportCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorsManager.primaryColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline_rounded,
              color: ColorsManager.primaryColor,
              size: 28,
            ),
          ),
          verticalSpace12,
          Text(
            appTranslation().get('privacy_ask_extra_title'),
            style: TextStylesManager.bold16.copyWith(
              color: ColorsManager.mainText,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace6,
          Text(
            appTranslation().get('privacy_ask_extra_desc'),
            style: TextStylesManager.regular12.copyWith(
              color: ColorsManager.placeholder,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace16,
          ElevatedButton(
            onPressed: () => context.push(Routes.createTicket),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 12,
              ),
              elevation: 0,
            ),
            child: Text(
              appTranslation().get('privacy_contact_support_btn'),
              style: TextStylesManager.bold14.copyWith(
                color: ColorsManager.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
