import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/features/login/presentation/cubit/login_cubit.dart';
import 'package:moean/features/login/presentation/cubit/login_state.dart';
import 'package:moean/features/login/presentation/widgets/login_action_buttons_widget.dart';
import 'package:moean/features/login/presentation/widgets/login_footer_widget.dart';
import 'package:moean/features/login/presentation/widgets/login_form_widget.dart';
import 'package:moean/features/login/presentation/widgets/login_header_widget.dart';
import 'package:moean/features/login/presentation/widgets/login_remember_forgot_widget.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BlocListener<LoginCubit, LoginState>(
        listener: _onStateChanged,
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return Scaffold(
              backgroundColor: ColorsManager.background,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Builder(
                builder: (context) {
                  final cubit = LoginCubit.get(context);
                  return Form(
                    key: cubit.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        verticalSpace16,
                        // ignore: prefer_const_constructors
                        LoginHeaderWidget(),
                  Container(
                     height: 300,
                      width: double.infinity,
                    decoration: BoxDecoration(
                      color: ColorsManager.background,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child:      Image.asset(
            AssetsHelper.img6,
            
          ),
                  ),
                        // ignore: prefer_const_constructors
                        LoginFormWidget(),
                        verticalSpace16,
                        // ignore: prefer_const_constructors
                        LoginRememberForgotWidget(),
                        verticalSpace28,
                        // ignore: prefer_const_constructors
                        LoginActionButtonsWidget(),
                        verticalSpace24,
                        // ignore: prefer_const_constructors
                        LoginFooterWidget(),
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

  void _onStateChanged(BuildContext context, LoginState state) {
    if (state is LoginErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: ColorsManager.errorColor,
        ),
      );
    }
    if (state is LoginSuccessState) {
      if (state.madrasatiConnected) {
        context.pushNamedAndRemoveUntil(Routes.home, (route) => false);
      } else {
        context.pushNamedAndRemoveUntil(
            Routes.loginMicrosoft, (route) => false);
      }
    }
  }

}
