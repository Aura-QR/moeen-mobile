import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
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
              onPressed: 
              (){
                context.push(Routes.schedule);
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
      verticalSpace20,
        Row(
          children: [
            const Expanded(child: Divider(color: ColorsManager.themeDivider)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                appTranslation().get('or'),
                style: TextStylesManager.regular14.copyWith(
                  color: ColorsManager.textBody,
                ),
              ),
            ),
            const Expanded(child: Divider(color: ColorsManager.themeDivider)),
          ],
        ),
        verticalSpace20,
        PrimaryElevatedButton(
          text: appTranslation().get('register_microsoft'),
          onPressed: () {
            context.push(Routes.loginMicrosoft);
          },
           borderSide:  BorderSide(
    color: ColorsManager.primaryColor,
    width: 2,
  ),
          backgroundColor: ColorsManager.surfacePrimary,
           icon: Image.asset(AssetsHelper.microsoft),

          textStyle: TextStylesManager.medium14.copyWith(
            color: ColorsManager.textPrimary,
          ),
        ),
      
      ],
    );
  }
}

