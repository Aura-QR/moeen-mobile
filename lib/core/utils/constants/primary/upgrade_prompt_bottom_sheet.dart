import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';

class UpgradePromptBottomSheet extends StatelessWidget {
  final String message;
  final bool isQuotaExceeded;

  const UpgradePromptBottomSheet({
    super.key,
    required this.message,
    required this.isQuotaExceeded,
  });

  static Future<void> show(BuildContext context, {required String message, required bool isQuotaExceeded}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.surfacePrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => UpgradePromptBottomSheet(
        message: message,
        isQuotaExceeded: isQuotaExceeded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 32,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isQuotaExceeded ? Icons.hourglass_empty_rounded : Icons.workspace_premium_rounded,
            size: 64,
            color: ColorsManager.primaryColor,
          ),
          verticalSpace16,
          Text(
            isQuotaExceeded ? 'نفد الرصيد!' : 'ترقية الحساب المطلوبة',
            style: TextStylesManager.bold20.copyWith(color: ColorsManager.mainText),
            textAlign: TextAlign.center,
          ),
          verticalSpace8,
          Text(
            message,
            style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
            textAlign: TextAlign.center,
          ),
          verticalSpace24,
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildBenefit('وصول غير محدود لكل المزايا'),
                verticalSpace8,
                _buildBenefit('أولوية الدعم الفني والمساعدة'),
                verticalSpace8,
                _buildBenefit('إعداد الدروس بنقرة واحدة'),
              ],
            ),
          ),
          verticalSpace32,
          PrimaryElevatedButton(
            text: 'عرض باقات الاشتراك',
            onPressed: () {
              Navigator.pop(context);
              context.push(Routes.checkout);
            },
            width: double.infinity,
          ),
          verticalSpace16,
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'لاحقاً',
              style: TextStylesManager.bold14.copyWith(color: ColorsManager.secondaryText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle_rounded, color: ColorsManager.primaryColor, size: 20),
        horizontalSpace12,
        Expanded(
          child: Text(
            text,
            style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
          ),
        ),
      ],
    );
  }
}
