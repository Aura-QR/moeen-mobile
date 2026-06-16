import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/login/presentation/cubit/login_cubit.dart';
import 'package:moean/features/login/presentation/cubit/login_state.dart';

class LoginRememberForgotWidget extends StatelessWidget {
  const LoginRememberForgotWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = LoginCubit.get(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            appTranslation().get('forgot_password'),
            style: TextStylesManager.regular14.copyWith(
              color: ColorsManager.primaryColor,
              decoration: TextDecoration.underline,
              decorationColor: ColorsManager.primaryColor,
            ),
          ),
        ),
        BlocBuilder<LoginCubit, LoginState>(
          buildWhen: (prev, curr) => curr is LoginRememberMeChangedState,
          builder: (context, state) {
            return Row(
              children: [
                Text(
                  appTranslation().get('remember_me'),
                  style: TextStylesManager.regular14.copyWith(
                    color: ColorsManager.textPrimaryLight,
                  ),
                ),
                Transform.scale(
                  scale: 0.9,
                  child: Checkbox(
                    value: cubit.rememberMe,
                    onChanged: (_) => cubit.toggleRememberMe(),
                    activeColor: ColorsManager.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(
                      color: ColorsManager.borderColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
