import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/features/login/presentation/cubit/login_cubit.dart';
import 'package:moean/features/login/presentation/cubit/login_state.dart';

class LoginActionButtonsWidget extends StatelessWidget {
  const LoginActionButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        BlocBuilder<LoginCubit, LoginState>(
          buildWhen: (prev, curr) =>
              curr is LoginLoadingState ||
              curr is LoginSuccessState ||
              curr is LoginErrorState ||
              curr is LoginInitialState,
          builder: (context, state) {
            return PrimaryElevatedButton(
              text: appTranslation().get('login'),
              onPressed: () {
                final cubit = LoginCubit.get(context);
                cubit.login();
              },
              isLoading: state is LoginLoadingState,
              icon: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 18,
              ),
              textStyle: TextStylesManager.bold16.copyWith(
                color: ColorsManager.white,
              ),
            );
          },
        ),
     
      ],
    );
  }
}

