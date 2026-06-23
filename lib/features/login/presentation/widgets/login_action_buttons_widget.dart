import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/login/presentation/cubit/login_cubit.dart';
import 'package:moean/features/login/presentation/cubit/login_state.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class LoginActionButtonsWidget extends StatefulWidget {
  const LoginActionButtonsWidget({super.key});

  @override
  State<LoginActionButtonsWidget> createState() => _LoginActionButtonsWidgetState();
}

class _LoginActionButtonsWidgetState extends State<LoginActionButtonsWidget> {
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    final cubit = LoginCubit.get(context);

    return Column(
      children: [
        BlocListener<LoginCubit, LoginState>(
          listenWhen: (prev, curr) =>
              curr is LoginLoadingState ||
              curr is LoginSuccessState ||
              curr is LoginErrorState ||
              curr is LoginInitialState,
          listener: (context, state) {
            if (state is LoginSuccessState) {
              _btnController.success();
            } else if (state is LoginErrorState) {
              _btnController.error();
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  _btnController.reset();
                }
              });
            } else if (state is LoginInitialState) {
              _btnController.reset();
            }
          },
          child: RoundedLoadingButton(
            controller: _btnController,
            onPressed: () {
              cubit.login();
            },
            color: ColorsManager.primaryColor,
            successColor: Colors.green,
            errorColor: ColorsManager.errorColor,
            width: MediaQuery.of(context).size.width,
            height: 52,
            borderRadius: 24,
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  appTranslation().get('login'),
                  style: TextStylesManager.bold16.copyWith(
                    color: ColorsManager.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

