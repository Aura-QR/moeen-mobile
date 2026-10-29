import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/email_block/presentation/cubit/email_block_state.dart';

/// Drives the «إعادة إرسال رسالة التأكيد» button inside [EmailBlockDialog].
///
/// Re-sends the confirmation email for an unverified free trial, using the
/// same `POST /api/auth/email/resend-verification` call as the verification
/// banner.
class EmailBlockCubit extends Cubit<EmailBlockState> {
  EmailBlockCubit() : super(const EmailBlockInitial());

  static EmailBlockCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> resendVerification({String? email}) async {
    if (state is EmailBlockResending) return;
    emit(const EmailBlockResending());

    final result = await ApiService.resendEmailVerification(email: email);

    result.fold(
      (error) => emit(EmailBlockResendError(error)),
      (data) {
        final message = data['message'] as String? ??
            appTranslation().get('resend_verification_sent');
        emit(EmailBlockResent(message));
      },
    );
  }
}
