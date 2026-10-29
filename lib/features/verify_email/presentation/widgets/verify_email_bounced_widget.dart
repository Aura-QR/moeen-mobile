import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/verify_email/presentation/cubit/verify_email_cubit.dart';
import 'package:moean/features/verify_email/presentation/cubit/verify_email_state.dart';

/// Shown when `GET /auth/email/status` reports the address bounced: it does not
/// exist. Replaces the instructions with a «correct your email» form wired to
/// `PATCH /auth/email`.
class VerifyEmailBouncedWidget extends StatefulWidget {
  const VerifyEmailBouncedWidget({super.key});

  @override
  State<VerifyEmailBouncedWidget> createState() =>
      _VerifyEmailBouncedWidgetState();
}

class _VerifyEmailBouncedWidgetState extends State<VerifyEmailBouncedWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VerifyEmailCubit, VerifyEmailState>(
      buildWhen: (previous, current) => current is VerifyEmailBouncedState,
      builder: (context, state) {
        if (state is! VerifyEmailBouncedState) return const SizedBox.shrink();
        final cubit = VerifyEmailCubit.get(context);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ColorsManager.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.unsubscribe_outlined,
                color: ColorsManager.errorColor,
                size: 44,
              ),
            ),
            verticalSpace20,
            Text(
              appTranslation().get('verify_email_bounced_title'),
              style: TextStylesManager.bold20.copyWith(
                color: ColorsManager.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace12,
            Text(
              appTranslation()
                  .get('verify_email_bounced_message')
                  .replaceAll('{email}', state.email),
              style: TextStylesManager.regular14.copyWith(
                color: ColorsManager.placeholder,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace20,
            PrimaryTextField(
              controller: _controller,
              hint: appTranslation().get('verify_email_correct_hint'),
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              enabled: !state.isSubmitting,
              onFieldSubmitted: (_) => cubit.correctEmail(_controller.text),
            ),
            if (state.fieldError != null) ...[
              verticalSpace8,
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  state.fieldError!,
                  style: TextStylesManager.regular12.copyWith(
                    color: ColorsManager.errorColor,
                  ),
                ),
              ),
            ],
            verticalSpace20,
            PrimaryElevatedButton(
              text: appTranslation().get('verify_email_correct_btn'),
              height: 52,
              radius: 24,
              isLoading: state.isSubmitting,
              backgroundColor: ColorsManager.primaryColor,
              onPressed: () => cubit.correctEmail(_controller.text),
            ),
          ],
        );
      },
    );
  }
}
