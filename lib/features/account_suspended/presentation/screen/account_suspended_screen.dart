import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/account_suspended/presentation/cubit/account_suspended_cubit.dart';
import 'package:moean/features/account_suspended/presentation/cubit/account_suspended_state.dart';
import 'package:moean/features/account_suspended/presentation/widgets/suspended_email_card_widget.dart';
import 'package:moean/features/account_suspended/presentation/widgets/suspended_notice_card_widget.dart';
import 'package:moean/features/account_suspended/presentation/widgets/suspended_ticket_form_card_widget.dart';
import 'package:moean/features/account_suspended/presentation/widgets/suspended_whatsapp_card_widget.dart';
import 'package:moean/features/account_suspended/presentation/widgets/suspended_working_hours_card_widget.dart';

class AccountSuspendedScreen extends StatelessWidget {
  final String? email;
  final String? password;
  final String? name;
  final String? phone;

  const AccountSuspendedScreen({
    super.key,
    this.email,
    this.password,
    this.name,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountSuspendedCubit()..loadContactTypes(),
      child: BlocListener<AccountSuspendedCubit, AccountSuspendedState>(
        listener: _onStateChanged,
        child: Scaffold(
          backgroundColor: ColorsManager.background,
          appBar: AppBar(
            backgroundColor: ColorsManager.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ColorsManager.textPrimary,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SuspendedNoticeCardWidget(
                    email: email,
                    password: password,
                  ),
                  verticalSpace16,
                  const SuspendedWhatsappCardWidget(),
                  verticalSpace16,
                  const SuspendedEmailCardWidget(),
                  verticalSpace16,
                  const SuspendedWorkingHoursCardWidget(),
                  verticalSpace16,
                  SuspendedTicketFormCardWidget(
                    email: email,
                    name: name,
                    phone: phone,
                  ),
                  verticalSpace32,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, AccountSuspendedState state) {
    if (state is AccountSuspendedActiveState) {
      context.pushNamedAndRemoveUntil(Routes.home, (route) => false);
    } else if (state is AccountSuspendedStillSuspendedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: ColorsManager.errorColor,
        ),
      );
    } else if (state is AccountSuspendedTicketSuccessState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: ColorsManager.successColor,
        ),
      );
    } else if (state is AccountSuspendedTicketErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: ColorsManager.errorColor,
        ),
      );
    }
  }
}
