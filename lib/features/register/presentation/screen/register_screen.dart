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
import 'package:moean/features/register/presentation/widgets/register_header_widget.dart';
import 'package:moean/features/register/presentation/widgets/register_illustration_widget.dart';
import 'package:moean/features/register/presentation/widgets/register_terms_widget.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';

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
                            const RegisterHeaderWidget(),
                            verticalSpace16,
                            const RegisterIllustrationWidget(),
                            verticalSpace24,
                            const RegisterFormWidget(),
                            verticalSpace20,
                            const RegisterAccountTypeWidget(),
                            verticalSpace16,
                            const RegisterTermsWidget(),
                            verticalSpace28,
                            const RegisterActionButtonsWidget(),
                            verticalSpace24,
                            const RegisterFooterWidget(),
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
    }
  }
}
