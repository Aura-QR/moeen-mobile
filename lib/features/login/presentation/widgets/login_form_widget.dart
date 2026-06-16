import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/login/presentation/cubit/login_cubit.dart';
import 'package:moean/features/login/presentation/cubit/login_state.dart';

class LoginFormWidget extends StatelessWidget {
  const LoginFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = LoginCubit.get(context);

    return Column(
    //  crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          appTranslation().get('welcome_back'),
          style: TextStylesManager.bold26.copyWith(
            color: ColorsManager.textPrimaryLight,
          ),
        ),
        verticalSpace8,
        Text(
          appTranslation().get('login_subtitle'),
          style: TextStylesManager.regular14.copyWith(
            color: ColorsManager.textBody,
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpace28,
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          
          children: [
            Text(
              appTranslation().get('email'),
              style: TextStylesManager.medium14.copyWith(
                color: ColorsManager.textPrimaryLight,
              ),
            ),
          ],
        ),
        verticalSpace8,
        PrimaryTextField(
          controller: cubit.emailController,
          hint: appTranslation().get('email_hint'),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: const Icon(Icons.mail_outline_rounded),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return appTranslation().get('email');
            }
            return null;
          },
        ),
        verticalSpace20,
        Row(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            Text(
              appTranslation().get('password'),
              style: TextStylesManager.medium14.copyWith(
                color: ColorsManager.textPrimaryLight,
              ),
            ),
          ],
        ),
        verticalSpace8,
        BlocBuilder<LoginCubit, LoginState>(
          buildWhen: (prev, curr) =>
              curr is LoginPasswordVisibilityChangedState,
          builder: (context, state) {
            return PrimaryTextField(
              controller: cubit.passwordController,
              hint: appTranslation().get('password_hint'),
              isPassword: !cubit.isPasswordVisible,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: GestureDetector(
                onTap: cubit.togglePasswordVisibility,
                child: Icon(
                  cubit.isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: ColorsManager.textBody,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return appTranslation().get('password');
                }
                return null;
              },
            );
          },
        ),
      ],
    );
  }
}
