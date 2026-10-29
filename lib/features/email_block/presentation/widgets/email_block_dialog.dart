import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/services/email_block_service.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/email_block/presentation/cubit/email_block_cubit.dart';
import 'package:moean/features/email_block/presentation/cubit/email_block_state.dart';

/// Shown globally when the backend refuses an AI tool or preparation call with
/// `email_bounced` / `email_unverified`. Renders the backend [EmailBlockEvent]
/// message as-is and offers the one action that unblocks the trial:
/// «تواصل معنا» for a bounced address, «إعادة إرسال رسالة التأكيد» otherwise.
class EmailBlockDialog extends StatelessWidget {
  final EmailBlockEvent event;

  const EmailBlockDialog({super.key, required this.event});

  static Future<void> show(BuildContext context, EmailBlockEvent event) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider(
        create: (_) => EmailBlockCubit(),
        child: EmailBlockDialog(event: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBounced = event.kind == EmailBlockKind.bounced;
    final String title = appTranslation().get(
      isBounced ? 'email_block_bounced_title' : 'email_block_unverified_title',
    );
    final String actionText = appTranslation().get(
      isBounced ? 'email_block_contact_btn' : 'email_block_resend_btn',
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: BlocConsumer<EmailBlockCubit, EmailBlockState>(
          listener: (context, state) {
            if (state is EmailBlockResent) {
              showPrimarySnackBar(context, state.message, isError: false);
              Navigator.of(context).pop();
            }
            if (state is EmailBlockResendError) {
              showPrimarySnackBar(context, state.message);
            }
          },
          buildWhen: (previous, current) =>
              current is EmailBlockResending || current is EmailBlockInitial,
          builder: (context, state) {
            final bool isResending = state is EmailBlockResending;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isBounced
                        ? Icons.mark_email_unread_rounded
                        : Icons.mark_email_read_rounded,
                    color: ColorsManager.primaryColor,
                    size: 36,
                  ),
                ),
                verticalSpace20,
                Text(
                  title,
                  style: TextStylesManager.bold20
                      .copyWith(color: ColorsManager.textPrimary),
                  textAlign: TextAlign.center,
                ),
                verticalSpace12,
                Text(
                  event.message,
                  style: TextStylesManager.medium14
                      .copyWith(color: ColorsManager.textPrimary),
                  textAlign: TextAlign.center,
                ),
                verticalSpace24,
                PrimaryElevatedButton(
                  text: actionText,
                  isLoading: isResending,
                  onPressed: () {
                    if (isBounced) {
                      Navigator.of(context).pop();
                      context.push(Routes.contact);
                    } else {
                      EmailBlockCubit.get(context)
                          .resendVerification(email: event.email);
                    }
                  },
                ),
                verticalSpace12,
                TextButton(
                  onPressed:
                      isResending ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    appTranslation().get('email_block_later_btn'),
                    style: TextStylesManager.bold14
                        .copyWith(color: ColorsManager.textPrimary),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
