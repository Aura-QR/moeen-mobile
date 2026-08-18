import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/register/presentation/cubit/register_cubit.dart';
import 'package:moean/features/register/presentation/cubit/register_state.dart';
import 'package:moean/features/register/presentation/widgets/register_account_type_widget.dart';
import 'package:moean/features/register/presentation/widgets/register_action_buttons_widget.dart';
import 'package:moean/features/register/presentation/widgets/register_footer_widget.dart';
import 'package:moean/features/register/presentation/widgets/register_form_widget.dart';
import 'package:moean/features/register/presentation/widgets/register_illustration_widget.dart';
import 'package:moean/features/register/presentation/widgets/register_terms_widget.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/core/theme/text_styles.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(),
      child: BlocListener<RegisterCubit, RegisterState>(
        listener: _onStateChanged,
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ),
              backgroundColor: ColorsManager.background,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Builder(
                    builder: (context) {
                      final cubit = RegisterCubit.get(context);
                      return Form(
                        key: cubit.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            verticalSpace16,
                            // ignore: prefer_const_constructors
                         //   RegisterHeaderWidget(),
                            verticalSpace16,
                            // ignore: prefer_const_constructors
                            RegisterIllustrationWidget(),
                            verticalSpace16,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: ColorsManager.primaryColor.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star_rounded, color: ColorsManager.primaryColor, size: 24),
                                  horizontalSpace8,
                                  Expanded(
                                    child: Text(
                                      'سجل الآن واحصل على تجربة مجانية كاملة لمدة 7 أيام بدون أي رسوم.',
                                      style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            verticalSpace24,
                            // ignore: prefer_const_constructors
                            RegisterFormWidget(),
                            verticalSpace20,
                            // ignore: prefer_const_constructors
                            RegisterAccountTypeWidget(),
                            verticalSpace16,
                            // ignore: prefer_const_constructors
                            RegisterTermsWidget(),
                            verticalSpace28,
                            // ignore: prefer_const_constructors
                            RegisterActionButtonsWidget(),
                            verticalSpace24,
                            // ignore: prefer_const_constructors
                            RegisterFooterWidget(),
                            verticalSpace32,
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, RegisterState state) {
    if (state is RegisterErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: ColorsManager.errorColor,
        ),
      );
    }
    if (state is RegisterSuccessState) {
      context.pushNamedAndRemoveUntil(Routes.home, (route) => false);
    }
  }
}
