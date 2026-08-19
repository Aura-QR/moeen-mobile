abstract class ResetPasswordState {
  const ResetPasswordState();
}

class ResetPasswordInitialState extends ResetPasswordState {
  const ResetPasswordInitialState();
}

class ResetPasswordLoadingState extends ResetPasswordState {
  const ResetPasswordLoadingState();
}

class ResetPasswordObscureToggledState extends ResetPasswordState {
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  const ResetPasswordObscureToggledState({
    required this.obscurePassword,
    required this.obscureConfirmPassword,
  });
}

class ResetPasswordSuccessState extends ResetPasswordState {
  final String message;
  const ResetPasswordSuccessState({required this.message});
}

class ResetPasswordErrorState extends ResetPasswordState {
  final String message;
  const ResetPasswordErrorState({required this.message});
}
