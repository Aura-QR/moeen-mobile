import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/verify_email/presentation/cubit/verify_email_cubit.dart';
import 'package:moean/features/verify_email/presentation/cubit/verify_email_state.dart';

class VerifyEmailActionsWidget extends StatelessWidget {
  const VerifyEmailActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VerifyEmailCubit, VerifyEmailState>(
      buildWhen: (previous, current) =>
          current is VerifyEmailCooldownTickState ||
          current is VerifyEmailResendLoadingState ||
          current is VerifyEmailResendSuccessState ||
          current is VerifyEmailErrorState,
      builder: (context, state) {
        final cubit = VerifyEmailCubit.get(context);
        final bool isCooldown = cubit.cooldownSeconds > 0;
        final bool isLoading = cubit.isResending;

        final String resendLabel = isCooldown
            ? appTranslation()
                .get('resend_verification_cooldown')
                .replaceAll('{seconds}', cubit.cooldownSeconds.toString())
            : appTranslation().get('resend_verification_link');

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: isCooldown || isLoading
                    ? null
                    : () {
                        cubit.resendVerificationEmail();
                      },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isCooldown
                        ? ColorsManager.placeholder.withValues(alpha: 0.5)
                        : ColorsManager.primaryColor,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: Colors.transparent,
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ColorsManager.primaryColor,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 20,
                            color: isCooldown
                                ? ColorsManager.placeholder
                                : ColorsManager.primaryColor,
                          ),
                          horizontalSpace8,
                          Text(
                            resendLabel,
                            style: TextStylesManager.bold14.copyWith(
                              color: isCooldown
                                  ? ColorsManager.placeholder
                                  : ColorsManager.primaryColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            verticalSpace14,
            PrimaryElevatedButton(
              text: appTranslation().get('continue_to_platform'),
              height: 52,
              radius: 24,
              isLoading: cubit.isChecking,
              backgroundColor: ColorsManager.primaryColor,
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                cubit.checkVerificationStatus();
              },
            ),
          ],
        );
      },
    );
  }
}
