abstract class VerifyEmailState {}

class VerifyEmailInitialState extends VerifyEmailState {}

class VerifyEmailLoadingState extends VerifyEmailState {}

class VerifyEmailResendLoadingState extends VerifyEmailState {}

class VerifyEmailResendSuccessState extends VerifyEmailState {
  final String message;
  VerifyEmailResendSuccessState({required this.message});
}

class VerifyEmailCooldownTickState extends VerifyEmailState {
  final int cooldownSeconds;
  VerifyEmailCooldownTickState({required this.cooldownSeconds});
}

class VerifyEmailSuccessState extends VerifyEmailState {}

class VerifyEmailErrorState extends VerifyEmailState {
  final String message;
  VerifyEmailErrorState({required this.message});
}
