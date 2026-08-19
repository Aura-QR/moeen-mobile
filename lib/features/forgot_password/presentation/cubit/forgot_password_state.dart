abstract class ForgotPasswordState {
  const ForgotPasswordState();
}

class ForgotPasswordInitialState extends ForgotPasswordState {
  const ForgotPasswordInitialState();
}

class ForgotPasswordLoadingState extends ForgotPasswordState {
  const ForgotPasswordLoadingState();
}

class ForgotPasswordSentSuccessState extends ForgotPasswordState {
  final String message;
  const ForgotPasswordSentSuccessState({required this.message});
}

class ForgotPasswordCooldownTickState extends ForgotPasswordState {
  final int cooldownSeconds;
  const ForgotPasswordCooldownTickState({required this.cooldownSeconds});
}

class ForgotPasswordErrorState extends ForgotPasswordState {
  final String message;
  const ForgotPasswordErrorState({required this.message});
}
