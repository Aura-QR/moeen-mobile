import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:moean/features/forgot_password/presentation/cubit/forgot_password_state.dart';

class ForgotPasswordSentWidget extends StatelessWidget {
  const ForgotPasswordSentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ForgotPasswordCubit.get(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.mark_email_read_rounded,
          size: 72,
          color: ColorsManager.primaryColor,
        ),
        verticalSpace16,
        Text(
          appTranslation().get('forgot_password_sent_title'),
          style: TextStylesManager.bold22.copyWith(
            color: ColorsManager.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpace12,
        Text(
          '${appTranslation().get('forgot_password_sent_desc_prefix')}${cubit.emailController.text}${appTranslation().get('forgot_password_sent_desc_suffix')}',
          style: TextStylesManager.regular14.copyWith(
            color: ColorsManager.placeholder,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpace24,
        BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
          buildWhen: (previous, current) =>
              current is ForgotPasswordCooldownTickState ||
              current is ForgotPasswordLoadingState,
          builder: (context, state) {
            final cooldown = cubit.cooldownSeconds;
            final isCooldown = cooldown > 0;
            final label = isCooldown
                ? appTranslation()
                    .get('forgot_password_resend_cooldown')
                    .replaceAll('{seconds}', '$cooldown')
                : appTranslation().get('forgot_password_resend_btn');

            return SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isCooldown
                        ? ColorsManager.borderColor
                        : ColorsManager.primaryColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: Icon(
                  Icons.refresh_rounded,
                  color: isCooldown
                      ? ColorsManager.placeholder
                      : ColorsManager.primaryColor,
                ),
                label: Text(
                  label,
                  style: TextStylesManager.bold14.copyWith(
                    color: isCooldown
                        ? ColorsManager.placeholder
                        : ColorsManager.primaryColor,
                  ),
                ),
                onPressed:
                    (isCooldown || cubit.isLoading) ? null : cubit.sendResetLink,
              ),
            );
          },
        ),
        verticalSpace12,
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            appTranslation().get('forgot_password_back_to_login'),
            style: TextStylesManager.medium14.copyWith(
              color: ColorsManager.placeholder,
            ),
          ),
        ),
      ],
    );
  }
}
