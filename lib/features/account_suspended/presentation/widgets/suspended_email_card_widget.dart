import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/account_suspended/presentation/cubit/account_suspended_cubit.dart';

class SuspendedEmailCardWidget extends StatelessWidget {
  const SuspendedEmailCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = AccountSuspendedCubit.get(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorsManager.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: InkWell(
              onTap: () => cubit.launchEmail('qraura0@gmail.com'),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ColorsManager.emailIconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.mail_outline_rounded,
                    color: ColorsManager.emailIconColor,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          verticalSpace12,
          Text(
            appTranslation().get('account_suspended_email_title'),
            style: TextStylesManager.bold18.copyWith(
              color: ColorsManager.textSecondaryDark,
            ),
          ),
          verticalSpace6,
          Text(
            appTranslation().get('account_suspended_email_desc'),
            style: TextStylesManager.regular13.copyWith(
              color: ColorsManager.placeholder,
            ),
          ),
          verticalSpace16,
          InkWell(
            onTap: () => cubit.launchEmail('qraura0@gmail.com'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: ColorsManager.emailIconColor,
                  ),
                  horizontalSpace6,
                  Text(
                    'qraura0@gmail.com',
                    style: TextStylesManager.bold14.copyWith(
                      color: ColorsManager.emailIconColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
