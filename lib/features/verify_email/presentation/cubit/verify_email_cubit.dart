import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/verify_email/presentation/cubit/verify_email_state.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState> with WidgetsBindingObserver {
  final String email;

  /// The address currently being confirmed. Starts as [email] and is replaced
  /// when the teacher corrects a bounced address.
  late String currentEmail;

  VerifyEmailCubit({required this.email}) : super(VerifyEmailInitialState()) {
    currentEmail = email;
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  static VerifyEmailCubit get(BuildContext context) => BlocProvider.of(context);

  // Poll `GET /auth/email/status` every 5s for up to 3 minutes.
  static const Duration _pollInterval = Duration(seconds: 5);
  static const int _maxPollAttempts = 36;

  int cooldownSeconds = 0;
  int _pollAttempts = 0;
  Timer? _cooldownTimer;
  Timer? _pollingTimer;
  bool isResending = false;
  bool isChecking = false;

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollAttempts = 0;
    _pollingTimer = Timer.periodic(_pollInterval, (timer) {
      if (state is VerifyEmailSuccessState || state is VerifyEmailBouncedState) {
        timer.cancel();
        return;
      }
      _pollAttempts++;
      if (_pollAttempts > _maxPollAttempts) {
        timer.cancel();
        return;
      }
      checkVerificationStatus(isSilent: true);
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
      final result = await ApiService.resendEmailVerification(email: currentEmail);
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
    if (isChecking ||
        state is VerifyEmailSuccessState ||
        state is VerifyEmailBouncedState) {
      return;
    }
    isChecking = true;

    if (!isSilent && !isClosed) emit(VerifyEmailLoadingState());

    try {
      final result = await ApiService.getEmailStatus();
      isChecking = false;
      if (isClosed) return;

      result.fold(
        (error) {
          if (!isSilent && !isClosed) emit(VerifyEmailErrorState(message: error));
        },
        (data) {
          final verified = data['verified'] == true;
          final bounced = data['bounced'] == true;
          final serverEmail = data['email']?.toString();
          if (serverEmail != null && serverEmail.isNotEmpty) {
            currentEmail = serverEmail;
          }

          if (verified) {
            _pollingTimer?.cancel();
            if (!isClosed) emit(VerifyEmailSuccessState());
          } else if (bounced) {
            _pollingTimer?.cancel();
            if (!isClosed) emit(VerifyEmailBouncedState(email: currentEmail));
          } else if (!isSilent && !isClosed) {
            emit(VerifyEmailErrorState(
                message: appTranslation().get('email_unverified_banner')));
          }
        },
      );
    } catch (e) {
      isChecking = false;
      if (!isSilent && !isClosed) emit(VerifyEmailErrorState(message: e.toString()));
    }
  }

  /// Submit a corrected address from the bounced form (`PATCH /auth/email`).
  /// On success: new address kept, a confirmation is re-sent, polling restarts.
  /// On 422/429 the message is shown under the field.
  Future<void> correctEmail(String newEmail) async {
    final current = state;
    if (current is! VerifyEmailBouncedState || current.isSubmitting) return;

    final trimmed = newEmail.trim();
    if (trimmed.isEmpty) {
      emit(current.copyWith(
          fieldError: appTranslation().get('verify_email_correct_required')));
      return;
    }

    emit(current.copyWith(isSubmitting: true, clearFieldError: true));

    final result = await ApiService.updateEmail(email: trimmed);
    if (isClosed) return;

    result.fold(
      (error) {
        final failure = failureFromApiError(error);
        String message;
        if (failure is ValidationFailure) {
          message = _firstEmailError(failure.errors) ?? failure.message;
        } else if (failure is RateLimitFailure) {
          message = appTranslation().get('verify_email_rate_limited');
        } else {
          message = appTranslation().get(failure.message);
        }
        final latest = state;
        if (!isClosed && latest is VerifyEmailBouncedState) {
          emit(latest.copyWith(isSubmitting: false, fieldError: message));
        }
      },
      (data) {
        final serverEmail = data['email']?.toString();
        currentEmail = (serverEmail != null && serverEmail.isNotEmpty)
            ? serverEmail
            : trimmed;
        // Back to the normal verify screen with the new address.
        if (!isClosed) {
          emit(VerifyEmailResendSuccessState(
              message: appTranslation().get('verify_email_corrected_sent')));
          emit(VerifyEmailInitialState());
        }
        startCooldown(60);
        _startPolling();
      },
    );
  }

  String? _firstEmailError(Map<String, dynamic> errors) {
    final value = errors['email'];
    if (value is List && value.isNotEmpty) return value.first.toString();
    if (value is String && value.isNotEmpty) return value;
    return null;
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
