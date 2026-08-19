import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/forgot_password/presentation/cubit/reset_password_cubit.dart';
import 'package:moean/features/forgot_password/presentation/cubit/reset_password_state.dart';

class ResetPasswordFormWidget extends StatelessWidget {
  const ResetPasswordFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ResetPasswordCubit.get(context);

    return Form(
      key: cubit.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              appTranslation().get('reset_password_new_label'),
              style: TextStylesManager.bold14.copyWith(
                color: ColorsManager.textPrimary,
              ),
            ),
          ),
          verticalSpace8,
          BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
            buildWhen: (previous, current) =>
                current is ResetPasswordObscureToggledState,
            builder: (context, state) {
              return PrimaryTextField(
                controller: cubit.passwordController,
                hint: appTranslation().get('reset_password_new_hint'),
                isPassword: cubit.obscurePassword,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    cubit.obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: ColorsManager.placeholder,
                    size: 20,
                  ),
                  onPressed: cubit.togglePasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return appTranslation().get('password_required');
                  }
                  if (value.length < 8) {
                    return appTranslation().get('reset_password_min_length');
                  }
                  return null;
                },
              );
            },
          ),
          verticalSpace16,
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              appTranslation().get('reset_password_confirm_label'),
              style: TextStylesManager.bold14.copyWith(
                color: ColorsManager.textPrimary,
              ),
            ),
          ),
          verticalSpace8,
          BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
            buildWhen: (previous, current) =>
                current is ResetPasswordObscureToggledState,
            builder: (context, state) {
              return PrimaryTextField(
                controller: cubit.confirmPasswordController,
                hint: appTranslation().get('reset_password_confirm_hint'),
                isPassword: cubit.obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    cubit.obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: ColorsManager.placeholder,
                    size: 20,
                  ),
                  onPressed: cubit.toggleConfirmPasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return appTranslation()
                        .get('confirm_password_required');
                  }
                  if (value != cubit.passwordController.text) {
                    return appTranslation().get('passwords_not_match');
                  }
                  return null;
                },
                onFieldSubmitted: (_) => cubit.resetPassword(),
              );
            },
          ),
          verticalSpace24,
          BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
            buildWhen: (previous, current) =>
                current is ResetPasswordLoadingState ||
                current is ResetPasswordErrorState ||
                current is ResetPasswordSuccessState,
            builder: (context, state) {
              return PrimaryElevatedButton(
                text: appTranslation().get('reset_password_submit_btn'),
                icon: const Icon(
                  Icons.vpn_key_outlined,
                  color: ColorsManager.white,
                  size: 20,
                ),
                isLoading: state is ResetPasswordLoadingState,
                onPressed: cubit.resetPassword,
              );
            },
          ),
        ],
      ),
    );
  }
}
