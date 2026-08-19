import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/forgot_password/presentation/cubit/reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final String email;
  final String token;

  ResetPasswordCubit({
    required this.email,
    required this.token,
  }) : super(const ResetPasswordInitialState());

  static ResetPasswordCubit get(BuildContext context) =>
      BlocProvider.of(context);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  bool isSuccess = false;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    if (!isClosed) {
      emit(ResetPasswordObscureToggledState(
        obscurePassword: obscurePassword,
        obscureConfirmPassword: obscureConfirmPassword,
      ));
    }
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    if (!isClosed) {
      emit(ResetPasswordObscureToggledState(
        obscurePassword: obscurePassword,
        obscureConfirmPassword: obscureConfirmPassword,
      ));
    }
  }

  Future<void> resetPassword() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isLoading) return;

    isLoading = true;
    if (!isClosed) emit(const ResetPasswordLoadingState());

    try {
      final result = await ApiService.resetPassword(
        email: email,
        token: token,
        password: passwordController.text,
        passwordConfirmation: confirmPasswordController.text,
      );
      if (isClosed) return;

      result.fold(
        (error) {
          isLoading = false;
          if (!isClosed) emit(ResetPasswordErrorState(message: error));
        },
        (data) {
          isLoading = false;
          isSuccess = true;
          final message = data['message'] as String? ??
              appTranslation().get('reset_password_success_title');
          if (!isClosed) {
            emit(ResetPasswordSuccessState(message: message));
          }
        },
      );
    } catch (e) {
      isLoading = false;
      if (!isClosed) emit(ResetPasswordErrorState(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}
