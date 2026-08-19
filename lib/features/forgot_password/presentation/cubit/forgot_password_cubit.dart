import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/forgot_password/presentation/cubit/forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(const ForgotPasswordInitialState());

  static ForgotPasswordCubit get(BuildContext context) =>
      BlocProvider.of(context);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  int cooldownSeconds = 0;
  Timer? _cooldownTimer;
  bool isSent = false;
  bool isLoading = false;

  void startCooldown([int seconds = 60]) {
    cooldownSeconds = seconds;
    _cooldownTimer?.cancel();
    if (!isClosed) {
      emit(ForgotPasswordCooldownTickState(cooldownSeconds: cooldownSeconds));
    }
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldownSeconds <= 1) {
        timer.cancel();
        cooldownSeconds = 0;
        if (!isClosed) {
          emit(const ForgotPasswordCooldownTickState(cooldownSeconds: 0));
        }
      } else {
        cooldownSeconds--;
        if (!isClosed) {
          emit(ForgotPasswordCooldownTickState(
              cooldownSeconds: cooldownSeconds));
        }
      }
    });
  }

  Future<void> sendResetLink() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return;
    }
    if (emailController.text.trim().isEmpty) return;
    if (isLoading || cooldownSeconds > 0) return;

    isLoading = true;
    if (!isClosed) emit(const ForgotPasswordLoadingState());

    try {
      final result =
          await ApiService.forgotPassword(emailController.text.trim());
      if (isClosed) return;

      result.fold(
        (error) {
          isLoading = false;
          if (!isClosed) emit(ForgotPasswordErrorState(message: error));
        },
        (data) {
          isLoading = false;
          isSent = true;
          startCooldown(60);
          final message = data['message'] as String? ??
              appTranslation().get('forgot_password_sent_title');
          if (!isClosed) {
            emit(ForgotPasswordSentSuccessState(message: message));
          }
        },
      );
    } catch (e) {
      isLoading = false;
      if (!isClosed) emit(ForgotPasswordErrorState(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    emailController.dispose();
    return super.close();
  }
}
