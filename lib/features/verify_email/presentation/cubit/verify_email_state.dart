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

/// The address bounced: it does not exist. The screen swaps its instructions
/// for a «correct your email» form. [fieldError] carries a 422/429 message
/// shown under the field; [isSubmitting] drives the «تصحيح» button spinner.
class VerifyEmailBouncedState extends VerifyEmailState {
  final String email;
  final bool isSubmitting;
  final String? fieldError;

  VerifyEmailBouncedState({
    required this.email,
    this.isSubmitting = false,
    this.fieldError,
  });

  VerifyEmailBouncedState copyWith({
    String? email,
    bool? isSubmitting,
    String? fieldError,
    bool clearFieldError = false,
  }) {
    return VerifyEmailBouncedState(
      email: email ?? this.email,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      fieldError: clearFieldError ? null : (fieldError ?? this.fieldError),
    );
  }
}

class VerifyEmailErrorState extends VerifyEmailState {
  final String message;
  VerifyEmailErrorState({required this.message});
}
