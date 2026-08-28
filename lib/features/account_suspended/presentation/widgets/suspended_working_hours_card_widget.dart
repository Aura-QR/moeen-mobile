import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/account_suspended/presentation/cubit/account_suspended_cubit.dart';

class SuspendedWorkingHoursCardWidget extends StatelessWidget {
  const SuspendedWorkingHoursCardWidget({super.key});

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
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ColorsManager.workingHoursIconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(
                  Icons.headset_mic_outlined,
                  color: ColorsManager.workingHoursIconColor,
                  size: 24,
                ),
              ),
            ),
          ),
          verticalSpace12,
          Text(
            appTranslation().get('account_suspended_working_hours_title'),
            style: TextStylesManager.bold18.copyWith(
              color: ColorsManager.textSecondaryDark,
            ),
          ),
          verticalSpace6,
          Text(
            appTranslation().get('account_suspended_working_hours_desc'),
            style: TextStylesManager.regular13.copyWith(
              color: ColorsManager.placeholder,
            ),
          ),
          verticalSpace16,
          InkWell(
            onTap: () => cubit.launchPhone('+966565101406'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: appTranslation().get('account_suspended_phone_prefix'),
                      style: TextStylesManager.regular14.copyWith(
                        color: ColorsManager.placeholder,
                      ),
                    ),
                    TextSpan(
                      text: appTranslation().get('account_suspended_phone_number'),
                      style: TextStylesManager.bold14.copyWith(
                        color: ColorsManager.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
