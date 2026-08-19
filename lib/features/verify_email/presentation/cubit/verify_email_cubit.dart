import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/verify_email/presentation/cubit/verify_email_state.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState> with WidgetsBindingObserver {
  final String email;

  VerifyEmailCubit({required this.email}) : super(VerifyEmailInitialState()) {
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  static VerifyEmailCubit get(BuildContext context) => BlocProvider.of(context);

  int cooldownSeconds = 0;
  Timer? _cooldownTimer;
  Timer? _pollingTimer;
  bool isResending = false;
  bool isChecking = false;

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (state is VerifyEmailSuccessState) {
        timer.cancel();
      } else {
        checkVerificationStatus(isSilent: true);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && this.state is! VerifyEmailSuccessState) {
      checkVerificationStatus(isSilent: true);
    }
  }

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
            _pollingTimer?.cancel();
            if (!isClosed) emit(VerifyEmailSuccessState());
            return;
          }
          startCooldown(60);
          final message = data['message'] as String? ?? appTranslation().get('resend_verification_sent');
          if (!isClosed) emit(VerifyEmailResendSuccessState(message: message));
        },
      );
    } catch (e) {
      isResending = false;
      if (!isClosed) emit(VerifyEmailErrorState(message: e.toString()));
    }
  }

  Future<void> checkVerificationStatus({bool isSilent = false}) async {
    if (isChecking || state is VerifyEmailSuccessState) return;
    isChecking = true;

    if (!isSilent && !isClosed) emit(VerifyEmailLoadingState());

    try {
      final result = await ApiService.getMe();
      isChecking = false;
      if (isClosed) return;

      result.fold(
        (error) {
          if (!isSilent && !isClosed) emit(VerifyEmailErrorState(message: error));
        },
        (user) {
          if (user.isEmailVerified) {
            _pollingTimer?.cancel();
            if (!isClosed) emit(VerifyEmailSuccessState());
          } else {
            if (!isSilent && !isClosed) {
              emit(VerifyEmailErrorState(message: appTranslation().get('email_unverified_banner')));
            }
          }
        },
      );
    } catch (e) {
      isChecking = false;
      if (!isSilent && !isClosed) emit(VerifyEmailErrorState(message: e.toString()));
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
          _pollingTimer?.cancel();
          if (!isClosed) emit(VerifyEmailSuccessState());
        },
      );
    } catch (e) {
      if (!isClosed) emit(VerifyEmailErrorState(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _cooldownTimer?.cancel();
    _pollingTimer?.cancel();
    return super.close();
  }
}
