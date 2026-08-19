import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:moean/features/forgot_password/presentation/cubit/forgot_password_state.dart';
import 'package:moean/features/forgot_password/presentation/widgets/forgot_password_badge_widget.dart';
import 'package:moean/features/forgot_password/presentation/widgets/forgot_password_form_widget.dart';
import 'package:moean/features/forgot_password/presentation/widgets/forgot_password_header_widget.dart';
import 'package:moean/features/forgot_password/presentation/widgets/forgot_password_sent_widget.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordCubit(),
      child: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
        listener: _onStateChanged,
        child: Scaffold(
          backgroundColor: ColorsManager.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: ColorsManager.primaryColor,
              ),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                  buildWhen: (previous, current) =>
                      current is ForgotPasswordSentSuccessState ||
                      previous is ForgotPasswordSentSuccessState,
                  builder: (context, state) {
                    final cubit = ForgotPasswordCubit.get(context);
                    if (cubit.isSent || state is ForgotPasswordSentSuccessState) {
                      return const ForgotPasswordSentWidget();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const ForgotPasswordBadgeWidget(),
                        verticalSpace20,
                        const ForgotPasswordHeaderWidget(),
                        verticalSpace24,
                        const ForgotPasswordFormWidget(),
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

  void _onStateChanged(BuildContext context, ForgotPasswordState state) {
    if (state is ForgotPasswordErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: ColorsManager.errorColor,
        ),
      );
    }
    if (state is ForgotPasswordSentSuccessState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: ColorsManager.primaryColor,
        ),
      );
    }
  }
}
