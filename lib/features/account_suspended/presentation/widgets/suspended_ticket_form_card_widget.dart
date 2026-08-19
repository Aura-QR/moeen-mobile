import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/account_suspended/presentation/cubit/account_suspended_cubit.dart';
import 'package:moean/features/account_suspended/presentation/cubit/account_suspended_state.dart';
import 'package:moean/features/account_suspended/presentation/widgets/suspended_ticket_type_dropdown_widget.dart';

class SuspendedTicketFormCardWidget extends StatelessWidget {
  final String? email;
  final String? name;
  final String? phone;

  const SuspendedTicketFormCardWidget({
    super.key,
    this.email,
    this.name,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountSuspendedCubit, AccountSuspendedState>(
      buildWhen: (previous, current) =>
          current is AccountSuspendedTicketSubmittingState ||
          current is AccountSuspendedTicketSuccessState ||
          current is AccountSuspendedTicketErrorState,
      builder: (context, state) {
        final cubit = AccountSuspendedCubit.get(context);
        final isSubmitting = state is AccountSuspendedTicketSubmittingState;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ColorsManager.borderColor,
              width: 1,
            ),
          ),
          child: Form(
            key: cubit.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  appTranslation().get('account_suspended_form_title'),
                  style: TextStylesManager.bold18.copyWith(
                    color: ColorsManager.textSecondaryDark,
                  ),
                ),
                verticalSpace6,
                Text(
                  appTranslation().get('account_suspended_form_desc'),
                  style: TextStylesManager.regular13.copyWith(
                    color: ColorsManager.placeholder,
                    height: 1.5,
                  ),
                ),
                verticalSpace20,
                Text(
                  appTranslation().get('account_suspended_ticket_type_label'),
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.textSecondaryDark,
                  ),
                ),
                verticalSpace8,
                const SuspendedTicketTypeDropdownWidget(),
                verticalSpace16,
                Text(
                  appTranslation().get('account_suspended_subject_label'),
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.textSecondaryDark,
                  ),
                ),
                verticalSpace8,
                PrimaryTextField(
                  controller: cubit.subjectController,
                  hint: appTranslation().get('account_suspended_subject_default'),
                ),
                verticalSpace16,
                Text(
                  appTranslation().get('account_suspended_message_label'),
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.textSecondaryDark,
                  ),
                ),
                verticalSpace8,
                PrimaryTextField(
                  controller: cubit.messageController,
                  hint: appTranslation().get('account_suspended_message_hint'),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return appTranslation().get('account_suspended_message_required');
                    }
                    return null;
                  },
                ),
                verticalSpace24,
                PrimaryElevatedButton(
                  text: appTranslation().get('account_suspended_submit_btn'),
                  isLoading: isSubmitting,
                  icon: const Icon(
                    Icons.send_rounded,
                    size: 18,
                    color: ColorsManager.white,
                  ),
                  onPressed: () {
                    cubit.submitReviewTicket(
                      email: email,
                      name: name,
                      phone: phone,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
