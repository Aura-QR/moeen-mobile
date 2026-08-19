import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/account_suspended/presentation/cubit/account_suspended_cubit.dart';
import 'package:moean/features/account_suspended/presentation/cubit/account_suspended_state.dart';

class SuspendedStatusCheckWidget extends StatelessWidget {
  final String? email;
  final String? password;

  const SuspendedStatusCheckWidget({
    super.key,
    this.email,
    this.password,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountSuspendedCubit, AccountSuspendedState>(
      buildWhen: (previous, current) =>
          current is AccountSuspendedCheckingState ||
          current is AccountSuspendedActiveState ||
          current is AccountSuspendedStillSuspendedState,
      builder: (context, state) {
        final cubit = AccountSuspendedCubit.get(context);
        final isChecking = state is AccountSuspendedCheckingState;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: ColorsManager.brandGold,
                ),
                horizontalSpace6,
                Expanded(
                  child: Text(
                    appTranslation().get('account_suspended_check_prompt'),
                    style: TextStylesManager.medium13.copyWith(
                      color: ColorsManager.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            verticalSpace12,
            Align(
              alignment: Alignment.centerLeft,
              child: PrimaryElevatedButton(
                width: 200,
                height: 44,
                radius: 12,
                text: appTranslation().get('account_suspended_check_status_btn'),
                isLoading: isChecking,
                icon: const Icon(
                  Icons.sync_rounded,
                  size: 20,
                  color: ColorsManager.white,
                ),
                onPressed: () {
                  cubit.checkStatus(
                    email: email,
                    password: password,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
