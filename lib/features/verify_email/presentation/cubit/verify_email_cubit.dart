import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/verify_email/presentation/cubit/verify_email_state.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  final String email;

  VerifyEmailCubit({required this.email}) : super(VerifyEmailInitialState());

  static VerifyEmailCubit get(BuildContext context) => BlocProvider.of(context);

  int cooldownSeconds = 0;
  Timer? _cooldownTimer;
  bool isResending = false;

  void startCooldown([int seconds = 60]) {
    cooldownSeconds = seconds;
    _cooldownTimer?.cancel();
    if (!isClosed) emit(VerifyEmailCooldownTickState(cooldownSeconds: cooldownSeconds));
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldownSeconds <= 1) {
        timer.cancel();
        cooldownSeconds = 0;
        if (!isClosed) emit(VerifyEmailCooldownTickState(cooldownSeconds: 0));
      } else {
        cooldownSeconds--;
        if (!isClosed) emit(VerifyEmailCooldownTickState(cooldownSeconds: cooldownSeconds));
      }
    });
  }

  Future<void> resendVerificationEmail() async {
    if (cooldownSeconds > 0 || isResending) return;

    isResending = true;
    if (!isClosed) emit(VerifyEmailResendLoadingState());

    try {
      final result = await ApiService.resendEmailVerification(email: email);
      if (isClosed) return;

      result.fold(
        (error) {
          isResending = false;
          if (!isClosed) emit(VerifyEmailErrorState(message: error));
        },
        (data) {
          isResending = false;
          if (data['already_verified'] == true) {
            if (!isClosed) emit(VerifyEmailSuccessState());
            return;
          }
          startCooldown(60);
          final message = data['message'] as String? ?? 'تم إرسال رابط تأكيد جديد إلى بريدك';
          if (!isClosed) emit(VerifyEmailResendSuccessState(message: message));
        },
      );
    } catch (e) {
      isResending = false;
      if (!isClosed) emit(VerifyEmailErrorState(message: e.toString()));
    }
  }

  Future<void> checkVerificationStatus() async {
    if (!isClosed) emit(VerifyEmailLoadingState());

    try {
      final result = await ApiService.getMe();
      if (isClosed) return;

      result.fold(
        (error) {
          if (!isClosed) emit(VerifyEmailErrorState(message: error));
        },
        (user) {
          if (user.isEmailVerified) {
            if (!isClosed) emit(VerifyEmailSuccessState());
          } else {
            if (!isClosed) emit(VerifyEmailInitialState());
          }
        },
      );
    } catch (e) {
      if (!isClosed) emit(VerifyEmailErrorState(message: e.toString()));
    }
  }

  Future<void> verifyEmailToken({
    required String id,
    required String hash,
    required String expires,
    required String signature,
  }) async {
    if (!isClosed) emit(VerifyEmailLoadingState());

    try {
      final result = await ApiService.verifyEmailToken(
        id: id,
        hash: hash,
        expires: expires,
        signature: signature,
      );
      if (isClosed) return;

      result.fold(
        (error) {
          if (!isClosed) emit(VerifyEmailErrorState(message: error));
        },
        (user) {
          if (!isClosed) emit(VerifyEmailSuccessState());
        },
      );
    } catch (e) {
      if (!isClosed) emit(VerifyEmailErrorState(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    return super.close();
  }
}
