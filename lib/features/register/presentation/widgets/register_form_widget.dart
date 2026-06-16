import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/register/presentation/cubit/register_cubit.dart';
import 'package:moean/features/register/presentation/cubit/register_state.dart';

class RegisterFormWidget extends StatelessWidget {
  const RegisterFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = RegisterCubit.get(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appTranslation().get('full_name'),
          style: TextStylesManager.medium14.copyWith(
            color: ColorsManager.textPrimaryLight,
          ),
        ),
        verticalSpace8,
        PrimaryTextField(
          controller: cubit.fullNameController,
          hint: appTranslation().get('full_name_hint'),
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          prefixIcon: const Icon(Icons.person_outline_rounded),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return appTranslation().get('full_name_required');
            }
            return null;
          },
        ),
        verticalSpace20,
        Text(
          appTranslation().get('email'),
          style: TextStylesManager.medium14.copyWith(
            color: ColorsManager.textPrimaryLight,
          ),
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
              return appTranslation().get('email_required');
            }
            final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value.trim())) {
              return appTranslation().get('email_invalid');
            }
            return null;
          },
        ),
        verticalSpace20,
        Text(
          appTranslation().get('phone'),
          style: TextStylesManager.medium14.copyWith(
            color: ColorsManager.textPrimaryLight,
          ),
        ),
        verticalSpace8,
        _PhoneFieldWidget(cubit: cubit),
        verticalSpace20,
        Text(
          appTranslation().get('password'),
          style: TextStylesManager.medium14.copyWith(
            color: ColorsManager.textPrimaryLight,
          ),
        ),
        verticalSpace8,
        BlocBuilder<RegisterCubit, RegisterState>(
          buildWhen: (prev, curr) =>
              curr is RegisterPasswordVisibilityChangedState,
          builder: (context, state) {
            return PrimaryTextField(
              controller: cubit.passwordController,
              hint: appTranslation().get('password_hint'),
              isPassword: !cubit.isPasswordVisible,
              textInputAction: TextInputAction.next,
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
                  return appTranslation().get('password_required');
                }
                return null;
              },
            );
          },
        ),
        verticalSpace20,
        Text(
          appTranslation().get('confirm_password'),
          style: TextStylesManager.medium14.copyWith(
            color: ColorsManager.textPrimaryLight,
          ),
        ),
        verticalSpace8,
        BlocBuilder<RegisterCubit, RegisterState>(
          buildWhen: (prev, curr) =>
              curr is RegisterConfirmPasswordVisibilityChangedState,
          builder: (context, state) {
            return PrimaryTextField(
              controller: cubit.confirmPasswordController,
              hint: appTranslation().get('confirm_password_hint'),
              isPassword: !cubit.isConfirmPasswordVisible,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: GestureDetector(
                onTap: cubit.toggleConfirmPasswordVisibility,
                child: Icon(
                  cubit.isConfirmPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: ColorsManager.textBody,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return appTranslation().get('confirm_password_required');
                }
                if (value != cubit.passwordController.text) {
                  return appTranslation().get('passwords_not_match');
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

class _PhoneFieldWidget extends StatelessWidget {
  final RegisterCubit cubit;

  const _PhoneFieldWidget({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PrimaryTextField(
            controller: cubit.phoneController,
            hint: appTranslation().get('phone_hint'),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.phone_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return appTranslation().get('phone_required');
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: ColorsManager.borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+966',
                style: TextStylesManager.medium14.copyWith(
                  color: ColorsManager.textPrimaryLight,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ColorsManager.textBody,
                size: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
