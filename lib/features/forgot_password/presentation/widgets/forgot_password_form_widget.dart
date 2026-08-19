import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:moean/features/forgot_password/presentation/cubit/forgot_password_state.dart';

class ForgotPasswordFormWidget extends StatelessWidget {
  const ForgotPasswordFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ForgotPasswordCubit.get(context);

    return Form(
      key: cubit.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              appTranslation().get('forgot_password_email_label'),
              style: TextStylesManager.bold14.copyWith(
                color: ColorsManager.textPrimary,
              ),
            ),
          ),
          verticalSpace8,
          PrimaryTextField(
            controller: cubit.emailController,
            hint: appTranslation().get('forgot_password_email_hint'),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            suffixIcon: Icon(
              Icons.mail_outline_rounded,
              color: ColorsManager.placeholder,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return appTranslation().get('forgot_password_email_required');
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return appTranslation().get('email_invalid');
              }
              return null;
            },
            onFieldSubmitted: (_) => cubit.sendResetLink(),
          ),
          verticalSpace24,
          BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
            buildWhen: (previous, current) =>
                current is ForgotPasswordLoadingState ||
                current is ForgotPasswordErrorState ||
                current is ForgotPasswordSentSuccessState,
            builder: (context, state) {
              return PrimaryElevatedButton(
                text: appTranslation().get('forgot_password_send_btn'),
                icon: const Icon(
                  Icons.vpn_key_outlined,
                  color: ColorsManager.white,
                  size: 20,
                ),
                isLoading: state is ForgotPasswordLoadingState,
                onPressed: cubit.sendResetLink,
              );
            },
          ),
        ],
      ),
    );
  }
}
