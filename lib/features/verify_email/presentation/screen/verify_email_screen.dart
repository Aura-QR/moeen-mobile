
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/verify_email/presentation/cubit/verify_email_cubit.dart';
import 'package:moean/features/verify_email/presentation/cubit/verify_email_state.dart';
import 'package:moean/features/verify_email/presentation/widgets/verify_email_actions_widget.dart';
import 'package:moean/features/verify_email/presentation/widgets/verify_email_badge_widget.dart';
import 'package:moean/features/verify_email/presentation/widgets/verify_email_header_widget.dart';
import 'package:moean/features/verify_email/presentation/widgets/verify_email_steps_widget.dart';
import 'package:moean/features/verify_email/presentation/widgets/verify_email_success_widget.dart';

class VerifyEmailScreen extends StatelessWidget {
  final String email;

  const VerifyEmailScreen({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerifyEmailCubit(email: email),
      child: BlocListener<VerifyEmailCubit, VerifyEmailState>(
        listener: _onStateChanged,
        child: Scaffold(
          backgroundColor: ColorsManager.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: BlocBuilder<VerifyEmailCubit, VerifyEmailState>(
              buildWhen: (previous, current) =>
                  current is VerifyEmailSuccessState ||
                  previous is VerifyEmailSuccessState,
              builder: (context, state) {
                if (state is VerifyEmailSuccessState) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
                child: BlocBuilder<VerifyEmailCubit, VerifyEmailState>(
                  buildWhen: (previous, current) =>
                      current is VerifyEmailSuccessState ||
                      current is VerifyEmailInitialState,
                  builder: (context, state) {
                    if (state is VerifyEmailSuccessState) {
                      return const VerifyEmailSuccessWidget();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const VerifyEmailBadgeWidget(),
                        verticalSpace20,
                        VerifyEmailHeaderWidget(email: email),
                        verticalSpace24,
                        const VerifyEmailStepsWidget(),
                        verticalSpace28,
                        const VerifyEmailActionsWidget(),
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

  void _onStateChanged(BuildContext context, VerifyEmailState state) {
    if (state is VerifyEmailErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: ColorsManager.errorColor,
        ),
      );
    }
    if (state is VerifyEmailResendSuccessState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.message.isNotEmpty
                ? state.message
                : appTranslation().get('resend_verification_sent'),
          ),
          backgroundColor: ColorsManager.primaryColor,
        ),
      );
    }
  }
}
