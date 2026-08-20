import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/formatters/saudi_phone_input_formatter.dart';
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
            color: ColorsManager.mainText,
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
            color: ColorsManager.mainText,
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
            color: ColorsManager.mainText,
          ),
        ),
        verticalSpace8,
        _PhoneFieldWidget(cubit: cubit),
        verticalSpace20,
        Text(
          appTranslation().get('password'),
          style: TextStylesManager.medium14.copyWith(
            color: ColorsManager.mainText,
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
            color: ColorsManager.mainText,
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
    return PrimaryTextField(
      controller: cubit.phoneController,
      hint: appTranslation().get('phone_hint'),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        SaudiPhoneInputFormatter(),
      ],
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      prefixIcon: Padding(
        padding: const EdgeInsetsDirectional.only(start: 14, end: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🇸🇦',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Text(
              '+966',
              textDirection: TextDirection.ltr,
              style: TextStylesManager.bold14.copyWith(
                color: ColorsManager.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 20,
              width: 1.5,
              color: ColorsManager.borderColor,
            ),
          ],
        ),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return appTranslation().get('phone_required');
        }
        final saudiPhoneRegex = RegExp(r'^(05\d{8}|5\d{8})$');
        if (!saudiPhoneRegex.hasMatch(text)) {
          return appTranslation().get('phone_invalid');
        }
        return null;
      },
    );
  }
}
