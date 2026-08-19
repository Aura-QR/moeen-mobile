import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/forgot_password/presentation/cubit/reset_password_cubit.dart';
import 'package:moean/features/forgot_password/presentation/cubit/reset_password_state.dart';
import 'package:moean/features/forgot_password/presentation/widgets/reset_password_form_widget.dart';
import 'package:moean/features/forgot_password/presentation/widgets/reset_password_header_widget.dart';
import 'package:moean/features/forgot_password/presentation/widgets/reset_password_success_widget.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String token;
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResetPasswordCubit(token: token, email: email),
      child: BlocListener<ResetPasswordCubit, ResetPasswordState>(
        listener: _onStateChanged,
        child: Scaffold(
          backgroundColor: ColorsManager.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              appTranslation().get('reset_password_appbar'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
              buildWhen: (previous, current) =>
                  current is ResetPasswordSuccessState ||
                  previous is ResetPasswordSuccessState,
              builder: (context, state) {
                final cubit = ResetPasswordCubit.get(context);
                if (cubit.isSuccess || state is ResetPasswordSuccessState) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: ColorsManager.primaryColor,
                  ),
                );
              },
            ),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                  buildWhen: (previous, current) =>
                      current is ResetPasswordSuccessState ||
                      previous is ResetPasswordSuccessState,
                  builder: (context, state) {
                    final cubit = ResetPasswordCubit.get(context);
                    if (cubit.isSuccess || state is ResetPasswordSuccessState) {
                      return const ResetPasswordSuccessWidget();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ResetPasswordHeaderWidget(email: email),
                        verticalSpace24,
                        const ResetPasswordFormWidget(),
                        verticalSpace20,
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, ResetPasswordState state) {
    if (state is ResetPasswordErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: ColorsManager.errorColor,
        ),
      );
    }
    if (state is ResetPasswordSuccessState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: ColorsManager.primaryColor,
        ),
      );
    }
  }
}
