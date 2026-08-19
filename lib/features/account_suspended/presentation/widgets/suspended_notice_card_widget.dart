import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/account_suspended/presentation/widgets/suspended_badge_widget.dart';
import 'package:moean/features/account_suspended/presentation/widgets/suspended_header_shield_icon_widget.dart';
import 'package:moean/features/account_suspended/presentation/widgets/suspended_status_check_widget.dart';

class SuspendedNoticeCardWidget extends StatelessWidget {
  final String? email;
  final String? password;

  const SuspendedNoticeCardWidget({
    super.key,
    this.email,
    this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ColorsManager.suspendedCardBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.errorColor.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SuspendedHeaderShieldIconWidget(),
          verticalSpace14,
          const SuspendedBadgeWidget(),
          verticalSpace16,
          Text(
            appTranslation().get('account_suspended_title'),
            style: TextStylesManager.bold20.copyWith(
              color: ColorsManager.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace12,
          Text(
            appTranslation().get('account_suspended_desc'),
            style: TextStylesManager.regular13.copyWith(
              color: ColorsManager.placeholder,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace20,
          Divider(
            color: ColorsManager.borderLightGray,
            thickness: 1,
          ),
          verticalSpace16,
          SuspendedStatusCheckWidget(
            email: email,
            password: password,
          ),
        ],
      ),
    );
  }
}
