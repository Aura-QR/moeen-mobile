import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/register/presentation/cubit/register_cubit.dart';
import 'package:moean/features/register/presentation/cubit/register_state.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class RegisterActionButtonsWidget extends StatefulWidget {
  const RegisterActionButtonsWidget({super.key});

  @override
  State<RegisterActionButtonsWidget> createState() => _RegisterActionButtonsWidgetState();
}

class _RegisterActionButtonsWidgetState extends State<RegisterActionButtonsWidget> {
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    final cubit = RegisterCubit.get(context);

    return Column(
      children: [
        BlocListener<RegisterCubit, RegisterState>(
          listenWhen: (prev, curr) =>
              curr is RegisterLoadingState ||
              curr is RegisterSuccessState ||
              curr is RegisterErrorState ||
              curr is RegisterInitialState,
          listener: (context, state) {
            if (state is RegisterSuccessState) {
              _btnController.success();
            } else if (state is RegisterErrorState) {
              _btnController.error();
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  _btnController.reset();
                }
              });
            } else if (state is RegisterInitialState) {
              _btnController.reset();
            }
          },
          child: RoundedLoadingButton(
            controller: _btnController,
            onPressed: () {
              cubit.register();
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
                  appTranslation().get('register'),
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

